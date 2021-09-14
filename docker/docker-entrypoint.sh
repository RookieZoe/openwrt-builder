#!/bin/sh
# vim:sw=4:ts=4:et

set -e

LAN_ADDRESS=${LAN_ADDRESS:-192.168.1.2}
LAN_NETMASK=${LAN_NETMASK:-255.255.255.0}
LAN_GATEWAY=${LAN_GATEWAY:-192.168.1.1}

# there is /etc/uci-defaults/99-default-settings
# make sure network settings is after 99-default-settings
cat >> /etc/uci-defaults/999-default-settings<<EOF
uci set network.lan.proto='static'
uci set network.lan.ipaddr='$LAN_ADDRESS'
uci set network.lan.netmask='$LAN_NETMASK'
uci set network.lan.gateway='$LAN_GATEWAY'
uci commit network
exit 0
EOF

# todo: config backups

# FILE_DIR=/etc
# find "$FILE_DIR" -follow -type f -name "*" -print | while read -r file; do
#   relative_path="${file#FILE_DIR/}"
#   output_path="$output_dir/${relative_path}"
#   subdir=$(dirname "$relative_path")
#   # create a subdirectory where the template file exists
#   mkdir -p "$output_dir/$subdir"
#   echo >&3 "$ME: Running envsubst on $template to $output_path"
#   envsubst "$defined_envs" <"$template" >"$output_path"
# done

# if [ -z "$(ls -A /overlay/)" ]; then
#   echo >&3 "$ME: /overlay/ is empty, transfer file to overlay..."

#   cp -af /etc/ /overlay/etc/
#   rm -rf /etc/
#   ln -sf /overlay/etc/ /etc/

#   cp -af /usr/ /overlay/usr/
#   rm -rf /usr/
#   ln -sf /overlay/usr/ /usr/

#   cp -af /root/ /overlay/root/
#   rm -rf /root/
#   ln -sf /overlay/root/ /root/
# else
#   echo >&3 "$ME: /overlay/ is not empty, recover..."
#   ln -sf /overlay/etc/ /etc/
#   ln -sf /overlay/usr/ /usr/
#   ln -sf /overlay/root/ /root/
# fi

exec "$@"
