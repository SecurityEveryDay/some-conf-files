#!/bin/bash

apt install -y dovecot-core dovecot-imapd
dovecot --version

cp dovecot.conf /etc/dovecot/dovecot.conf
cp 10-mail.conf /etc/dovecot/conf.d/10-mail.conf
cp 10-auth.conf /etc/dovecot/conf.d/10-auth.conf
cp auth-system.conf.ext /etc/dovecot/conf.d/auth-system.conf.ext
cp 10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
cp 10-master.conf /etc/dovecot/conf.d/10-master.conf
sudo doveconf -n
systemctl restart dovecot
systemctl status dovecot
systemctl enable dovecot
