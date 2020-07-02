#!/bin/sh
set -e

case "$1" in
  'start' )
    rm -f /filesafe-relay/tmp/pids/server.pid
    [ ! -z "$GOOGLE_CLIENT_SECRETS" ] && echo "$GOOGLE_CLIENT_SECRETS" > /filesafe-relay/client_secrets.json
    bundle exec rails server -b 0.0.0.0
    ;;

   * )
    echo "Unknown command"
    ;;
esac

exec "$@"
