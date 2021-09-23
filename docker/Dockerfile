FROM scratch
LABEL maintainer="Rookie_Zoe <i@rookiezoe.com>"

ARG FIRMWARE
ARG R_VERSION
ENV R_VERSION=${R_VERSION}

ADD ${FIRMWARE} /
COPY docker-entrypoint.sh /.docker-entrypoint.sh

USER root

ENTRYPOINT ["sh", "/.docker-entrypoint.sh"]
CMD ["/sbin/init"]
