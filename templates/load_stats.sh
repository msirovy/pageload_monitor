#!/bin/bash
# gather detailed web response time and report it to influxdb

URL=$1
PURL=$(echo $URL | sed 's/\//_/g')
LOCATION=$(hostname -f | cut -d. -f2)
LOGIN="{{influx_login}}"
PASSWORD="{{influx_password}}"
INFLUX_URL='{{influx_url}}'


# Measure data
curl -L --output /dev/null --silent --show-error \
    --write-out "lookup_time,from=$LOCATION,url=$URL value=%{time_namelookup}\nconnect_time,from=$LOCATION,url=$URL value=%{time_connect}\nappconnect_time,from=$LOCATION,url=$URL value=%{time_appconnect}\npretransfer_time,from=$LOCATION,url=$URL value=%{time_pretransfer}\nredirect_time,from=$LOCATION,url=$URL value=%{time_redirect}\nstarttransfer_time,from=$LOCATION,url=$URL value=%{time_starttransfer}\ntotal_time,from=$LOCATION,url=$URL value=%{time_total}" \
    "$URL" > /tmp/load-$PURL.stats

# Report stats
curl -i -XPOST $INFLUX_URL \
    -u $LOGIN:$PASSWORD \
    --data-binary @/tmp/load-$PURL.stats -s -o /dev/null

echo "OK"
exit 0
