FROM ubuntu:22.04

RUN apt update -y
RUN apt install bind9 -y

COPY named.conf.local /etc/bind/named.conf.local
COPY db.secday.local /etc/bind/db.secday.local

RUN named-checkzone secday.local /etc/bind/db.secday.local

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/named","-g","-c","/etc/bind/named.conf"]
