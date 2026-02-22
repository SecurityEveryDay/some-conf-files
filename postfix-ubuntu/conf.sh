#!/bin/bash

hostname="mail.hr-corp.local"
ip="192.168.80.10"

apt install rsyslog -y
sudo hostnamectl set-hostname ${hostname}
echo 127.0.0.1 ${hostname} >> /etc/hosts
echo ${ip} ${hostname} >> /etc/hosts
apt update -y && apt install -y postfix mailutils iputils-ping
cp master.cf /etc/postfix/master.cf
cp main.cf /etc/postfix/main.cf

# Usuário vítima
sudo useradd -m -s /bin/bash jsilva
echo "jsilva:User@2023" | sudo chpasswd

# Usuário colega (para enviar e-mails legítimos antes do ataque)
sudo useradd -m -s /bin/bash mcontador
echo "mcontador:User@2023" | sudo chpasswd

# Confirme que foram criados
cat /etc/passwd | grep -E "jsilva|mcontador"

# Para jsilva
sudo mkdir -p /home/jsilva/Maildir/{new,cur,tmp}
sudo chown -R jsilva:jsilva /home/jsilva/Maildir
sudo chmod -R 700 /home/jsilva/Maildir

# Para mcontador
sudo mkdir -p /home/mcontador/Maildir/{new,cur,tmp}
sudo chown -R mcontador:mcontador /home/mcontador/Maildir
sudo chmod -R 700 /home/mcontador/Maildir

# Confirme as permissões
ls -la /home/jsilva/
ls -la /home/jsilva/Maildir/

sudo postfix check
sudo systemctl restart postfix
sudo systemctl enable postfix
sudo systemctl status postfix
sudo ss -tlnp | grep :25
sudo ss -tlnp | grep :587


# Envia e-mail de teste
echo "Postfix funcionando no laboratorio hr-corp" | \
  mail -s "Teste local" jsilva@hr-corp.local

# Aguarda e verifica
sleep 3
ls -la /home/jsilva/Maildir/new/

# Lê o conteúdo
cat /home/jsilva/Maildir/new/*
