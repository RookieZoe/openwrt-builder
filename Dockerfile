FROM scratch
LABEL maintainer="Rookie_Zoe <i@rookiezoe.com>"
ARG FIRMWARE
ADD ${FIRMWARE} /
# COPY docker-entrypoint.sh /docker-entrypoint.sh
EXPOSE 22 80 443
USER root
# ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/sbin/init"]
