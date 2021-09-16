FROM scratch
LABEL maintainer="Rookie_Zoe <i@rookiezoe.com>"

ARG FIRMWARE
ARG r_revision
ARG r_revision_l
ENV R_REVISION=${r_revision}
ENV R_REVISION_L=${r_revision_l}

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
