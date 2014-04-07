#!/bin/bash

epoch=$(date +%s)
wget -O zabbixmonitor-$epoch.tar.gz 

localbin=$HOME/bin
localgem=$HOME/.gem/ruby/1.9.1
mkdir $localbin
mkdir -p $localgem

if [ -d "$localbin" ] && [[ ! $PATH =~ (^|:)$localbin(:|$) ]]; then
  PATH+=:$localbin
else
  echo "Could not create $localbin or find it in PATH"
  exit
fi

if [ -d "$localgem" ] && [[ ! $(gem environment gemdir) == $localgem ]]; then

else
  echo "Could not create $localgem or verify that it is defined in your gem environment."
  exit
fi

tar xzvf zabbixmonitor-$epoch.tar.gz
mv zabbixmonitor/bin* $localbin/
mv zabbixmonitor/lib $HOME
mv zabbixmonitor/profiles.yml.example $HOME/profiles.yml
