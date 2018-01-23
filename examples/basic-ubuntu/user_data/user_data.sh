#!/bin/bash

install_precontions() {
	echo "Updating apt-get..."
	sudo apt-get update && apt-get upgrade -y > /tmp/install.log
	echo "Installing some other tools needed."
	sudo apt-get install -y unzip python zsh htop > /tmp/install.log
}

install_java() {
    echo "Installing Java..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qqy install openjdk-8-jre > /tmp/install.log
    echo "Done."
}

install_aws_cli() {
	echo "Installing AWS CLI.."
	sudo wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip > /tmp/install.log
	sudo unzip awscli-bundle.zip > /tmp/install.log
	sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws > /tmp/install.log
	echo "Done."
}

install_mysql_server() {
	echo "Installing MySQL Server 5.7.."
	echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections > /tmp/install.log
	echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections > /tmp/install.log
	sudo apt-get install -y mysql-server-5.7 > /tmp/install.log
	mysqladmin -u root -proot password '' > /tmp/install.log
	echo "Done."
}

install_precontions
install_java
install_aws_cli
install_mysql_server
