# Allmon3-Docker
 A Dockerised version of AllStarLink's Allmon3 Dashboard

## How to Use

Clone this repository to your desired location:

    git clone https://github.com/M8WAT/Allmon3-Docker.git

Open the folder:

    cd Allmon3-Docker

Edit the allmon.ini to point at your desired nodes:

    nano etc/allmon3.ini

Create the container:

    docker compose up -d


## Managing Users - Remember to restart the container once you have finished using:

# Add User(s) / Change User Password

Use the following command to add a user or change a current users password. Replace <USER> with your chosen username, and enter a password of your choosing when prompted:

    docker exec -it allmon3 allmon3-passwd <USER>

To apply the additions/changes, you must restart the container using the following command:

    docker container restart allmon3


# Remove User(s)

To remove a user, use the following command, replacing <USER> with the username you want to remove:

    docker exec -it allmon3 allmon3-passwd --delete <USER>

Restart the container to apply the changes:

    docker container restart allmon3
