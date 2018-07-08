#!/usr/bin/env bash
sudo apt-get install ntp -y
sudo -- sh -c 'echo "# for security" >> /etc/ntp.conf'  # to do (error)
sudo -- sh -c 'echo "disable monitor" >> /etc/ntp.conf'  # to do (error)

sudo service ntp restart
ntpdc -nc monlist localhost

echo "*** Server reports data not found." must be shown.
