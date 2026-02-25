#!/bin/sh

# Set Tailscale up flags
export TS_EXTRA_ARGS="--advertise-exit-node --ssh"
export TS_HOSTNAME="${TAILSCALE_HOSTNAME:-render-US}"
export TS_AUTHKEY="${TAILSCALE_AUTHKEY}"  # Pass auth key

# Start minimal web server for Render health checks (in background)
python3 -m http.server ${PORT:-10000} --directory /tmp &
echo "OK" > /tmp/index.html

# Start Tailscale with structured logging
exec /usr/local/bin/containerboot 2>&1 | jq -c -R --unbuffered '
  {
    level: (if contains("error") or contains("failed") or contains("fatal") then "ERROR" else "INFO" end),
    message: (. | sub("^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} "; "")),
    time: now | strflocaltime("%Y-%m-%dT%H:%M:%S%z")
  }'
