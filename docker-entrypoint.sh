#!/bin/sh
# vim:sw=4:ts=4:et
# not done yet
set -e

if [ -z "$(ls -A /overlay/)" ]; then
  echo >&3 "$ME: /overlay/ is empty, transfer file to overlay..."

  cp -af /etc/ /overlay/etc/
  rm -rf /etc/
  ln -sf /overlay/etc/ /etc/

  cp -af /usr/ /overlay/usr/
  rm -rf /usr/
  ln -sf /overlay/usr/ /usr/

  cp -af /root/ /overlay/root/
  rm -rf /root/
  ln -sf /overlay/root/ /root/
else
  echo >&3 "$ME: /overlay/ is not empty, recover..."
  ln -sf /overlay/etc/ /etc/
  ln -sf /overlay/usr/ /usr/
  ln -sf /overlay/root/ /root/
fi
