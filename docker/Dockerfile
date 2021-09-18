FROM scratch
LABEL maintainer="Rookie_Zoe <i@rookiezoe.com>"

ARG FIRMWARE
ARG r_revision
ENV R_REVISION=${r_revision}

ADD ${FIRMWARE} /
COPY docker-entrypoint.sh /.docker-entrypoint.sh

USER root

ENTRYPOINT ["sh", "/.docker-entrypoint.sh"]
CMD ["/sbin/init"]
