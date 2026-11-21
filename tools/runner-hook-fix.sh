#!/usr/bin/env bash
# Fixes the build queue on the build server: GitHub's runner only accepts hook scripts ending in .sh.
set -e
for f in build-queue-start build-queue-end; do
  if [ -f /usr/local/bin/$f ]; then mv -f /usr/local/bin/$f /usr/local/bin/$f.sh; fi
  [ -f /usr/local/bin/$f.sh ] && chmod 755 /usr/local/bin/$f.sh
done
for env in $(find /home/builder -name .env 2>/dev/null); do
  sed -i 's#/usr/local/bin/build-queue-start$#/usr/local/bin/build-queue-start.sh#; s#/usr/local/bin/build-queue-end$#/usr/local/bin/build-queue-end.sh#' "$env"
done
[ -f /usr/local/bin/connect-runner ] && sed -i 's#/usr/local/bin/build-queue-start\\n#/usr/local/bin/build-queue-start.sh\\n#; s#/usr/local/bin/build-queue-end\\n#/usr/local/bin/build-queue-end.sh\\n#' /usr/local/bin/connect-runner
for unit in /etc/systemd/system/actions.runner.*.service; do
  name=$(basename "$unit"); systemctl restart "$name"; echo "$name: $(systemctl is-active "$name")"
done
free -h | grep -i swap
echo "FIXED"
