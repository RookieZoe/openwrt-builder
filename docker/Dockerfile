FROM scratch
LABEL maintainer="Rookie_Zoe <i@rookiezoe.com>"

ARG FIRMWARE
ARG r_version
ENV R_VERSION=${r_version}

ADD ${FIRMWARE} /
COPY docker-entrypoint.sh /.docker-entrypoint.sh

USER root

ENTRYPOINT ["sh", "/.docker-entrypoint.sh"]
CMD ["/sbin/init"]
