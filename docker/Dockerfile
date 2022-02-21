FROM --platform=$TARGETPLATFORM scratch
LABEL maintainer="Rookie_Zoe <i@rookiezoe.com>"

ARG TARGETARCH
ARG R_VERSION
ENV R_VERSION=${R_VERSION}

ADD openwrt-21.02-${TARGETARCH}-rootfs.tar.gz /
COPY docker-entrypoint.sh /.docker-entrypoint.sh

USER root

ENTRYPOINT ["sh", "/.docker-entrypoint.sh"]
CMD ["/sbin/init"]
