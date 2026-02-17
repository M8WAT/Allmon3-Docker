# Created by Ashley Watmough - M8WAT
# Maintainer of XLX178 Multi-Mode Reflector - https://xlx.buxton.radio/
#
# Date First Created: 2025-02-16
# Date Last Modified: 2025-02-17
#
# The layout of the file has been optimised in the most part to 80 cols wide due
# to most of my coding being carried out on my iPhone.
#
# This has been inspired by, but heavily modified from, the original Dockerfile
# from the AllStarLink/Allmon3 repository for my use case.
#
# The main modifications are the integrating of all code into the Dockerfile
# itself (origianally used several external scripts), and changing the dashboard
# location from http://127.0.0.1/allmon3/ to http://127.0.0.1/

# Set Base Docker Image
FROM debian:13-slim AS base

# Set Working Directory
WORKDIR /root

# Update Base Image
RUN echo 'debconf debconf/frontend select Noninteractive' | \
    debconf-set-selections && \
    apt-get update && \
    apt-get upgrade -y

# Create Fake systemd Environment & Make Executable
RUN echo '\
    \r# /usr/bin/bash\n\
    \r\n\
    \rThis is to avoid problems with .postinst scripts\n\
    \r\n\
    \rexit 0\n\
    \r' > /usr/bin/systemctl && \
    chmod +x /usr/bin/systemctl

# Install Dependancies
RUN apt-get install -y \
	supervisor \
	wget

# Add AllStarLink Repository & Install Allmon3
ADD https://repo.allstarlink.org/public/asl-apt-repos.deb13_all.deb \
    asl-apt-repos.deb13_all.deb

RUN dpkg -i asl-apt-repos.deb13_all.deb && \
    apt-get update && \
    apt-get install -y allmon3

# Clean-up Image
RUN apt-get -y purge wget && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm asl-apt-repos.deb13_all.deb && \
    rm -rf /var/lib/apt-get/lists/*

# Change Apache2 Logging Paths
RUN sed -ri \
    -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
    -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
    -e 's!^(\s*TransferLog)\s+\S+!\1 /proc/self/fd/1!g' \
    "/etc/apache2/conf-available/other-vhosts-access-log.conf" \
    "/etc/apache2/sites-available/000-default.conf"

# Change Dashboard Location
# Modify the Default Apache2 site conf file target, disable allmon3.conf and
# integrate some of it's contents into the default site conf file.
RUN sed -ri -e 's!^(\s*DocumentRoot)\s+\S+!\1 /usr/share/allmon3!g' \
    "/etc/apache2/sites-available/000-default.conf" && \
    a2disconf allmon3.conf && \
    echo '\
    \r\n\
    \r<Directory /usr/share/allmon3>\n\
    \r\tAllowOverride all\n\
    \r\t\n\
    \r\t# Implement rewrite within the directory so that is survives\n\
    \r\t# into the <VirtualHost> tags\n\
    \r\tRewriteEngine On\n\
    \r\tRewriteCond %{HTTP:Upgrade} =websocket [NC]\n\
    \r\tRewriteRule ^ws/([0-9]+) ws://localhost:$1 [P,L,QSA]\n\
    \r</Directory>\n\
    \r\n\
    \r# Proxy cannot usefully occur inside a <Directory> on Debian\n\
    \rProxyAddHeaders On\n\
    \rProxyPreserveHost On\n\
    \rProxyPass /master/ "http://localhost:16080/"\n\
    \r' >> /etc/apache2/sites-available/000-default.conf

# Create Supervisor Process Controller Config
# These settings that Define Services to be Launched on the Containers Creation
RUN echo '\
    \r[supervisord]\n\
    \rnodaemon=true\n\
    \rstdout_logfile=/dev/fd/1\n\
    \rstdout_logfile_maxbytes=0\n\
    \r\n\
    \r[program:allmon3]\n\
    \rstdout_logfile=/dev/fd/1\n\
    \rstdout_logfile_maxbytes=0\n\
    \rcommand=/usr/bin/allmon3\n\
    \r\n\
    \r[program:apache2]\n\
    \rstdout_logfile=/dev/fd/1\n\
    \rstdout_logfile_maxbytes=0\n\
    \rcommand=apachectl -D FOREGROUND\n\
    \r' > /etc/supervisor/conf.d/supervisord.conf

# Expose HTTP Port to Access Allmon3 Dashboard
EXPOSE 80

# Launch Supervisor Process Controller
CMD ["/usr/bin/supervisord"]
