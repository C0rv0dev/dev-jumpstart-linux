#!/bin/bash
# change these values to match your environment
NODE_MAJOR=21
LOG_PATH=~/.logs
USERNAME="YOUR_USERNAME"

# create my logs
cd ~
mkdir -p $LOG_PATH

touch $LOG_PATH/installation_log_error.txt \
    $LOG_PATH/installation_log_success.txt

# Install Dependencies
add-apt-repository ppa:ondrej/php -y

apt update
apt install -y cowsay git code nodejs npm ca-certificates curl gnupg mysql-server apache2 php-cli php-mbstring php-curl unzip php >>$LOG_PATH/installation_log_success.txt 2>$LOG_PATH/installation_log_error.txt

# NPM and Nodejs Config
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Update already installed packages
apt update
apt install -y nodejs >>$LOG_PATH/installation_log_success.txt 2>$LOG_PATH/installation_log_error.txt

# Docker Config
apt remove docker-desktop -y
# remove if it exists
rm -r $HOME/.docker/desktop
rm /usr/local/bin/com.docker.cli
apt purge docker-desktop -y

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker Engine, containerd, and Docker Compose
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >>$LOG_PATH/installation_log_success.txt 2>$LOG_PATH/installation_log_error.txt

# Install Docker Desktop
wget -O docker-desktop.deb "https://desktop.docker.com/linux/main/amd64/docker-desktop-4.26.1-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"
dpkg -i docker-desktop.deb >>$LOG_PATH/installation_log_success.txt 2>$LOG_PATH/installation_log_error.txt
rm docker-desktop.deb

# Composer Config
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/compose

# Docker Post Install Config
groupadd docker
usermod -aG docker $USERNAME
newgrp docker
chown $USERNAME:$USERNAME /home/$USERNAME/.docker -R
chmod g+rwx "/home/$USERNAME/.docker" -R

echo "---------------------------------------------------------"
cowsay "Installation Completed"
echo "---------------------------------------------------------"
