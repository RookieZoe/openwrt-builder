FROM scratch
LABEL maintainer="Rookie_Zoe <i@rookiezoe.com>"

ENV LAN_ADDRESS=192.168.1.2
ENV LAN_NETMASK=255.255.255.0
ENV LAN_GATEWAY=192.168.1.1

ARG FIRMWARE
ADD ${FIRMWARE} /
COPY docker-entrypoint.sh /docker-entrypoint.sh

USER root
VOLUME /data

EXPOSE 22/tcp
EXPOSE 53/udp
EXPOSE 80/tcp
EXPOSE 443/tcp

ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
CMD ["/sbin/init"]
