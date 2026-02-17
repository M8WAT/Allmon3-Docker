# Allmon3-Docker

This is my AllStarLink Allmon3 Dashboard Docker Image based on Debian 13-slim (Trixie).

This has been inspired by, but heavily modified from, the original Dockerfile and associated from the [AllStarLink Allmon3 Repository](https://github.com/AllStarLink/Allmon3) for my use case.

The main modifications are the integrating of all code into the Dockerfile itself (which originally used several external scripts), and changing the dashboard location from http://127.0.0.1/allmon3/ to http://127.0.0.1:8008/. This is to allow a simpler integration with my reverse proxy setup.

## How to Use

Clone this repository to your desired location:

    git clone https://github.com/M8WAT/Allmon3-Docker.git

Open the folder:

    cd Allmon3-Docker

Edit the allmon.ini to point at your desired nodes:

    nano etc/allmon3.ini

Create the container:

    docker compose up -d

Access the dashboard at (Don't forget to add a user - see below):

    http://127.0.0.1:8008/

If you are trying to access the dashboard from another device on the same LAN, use the hosts IP address or hostname and port 8008.

Examples:

    http://192.168.0.5:8008

or

    http://myserver:8008


## Managing Users - Remember to Restart the Container When Finished

### Add User / Change User Password

Use the following command to add a user or change a current users password. Replace <USER> with your chosen username, and enter a password of your choosing when prompted:

    docker exec -it allmon3 allmon3-passwd <USER>

To apply the additions/changes, you must restart the container using the following command:

    docker container restart allmon3


### Remove User

To remove a user, use the following command, replacing <USER> with the username you want to remove:

    docker exec -it allmon3 allmon3-passwd --delete <USER>

Restart the container to apply the changes:

    docker container restart allmon3
