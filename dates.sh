#! /bin/env bash

# converts timestamp from "[DD-MM-YY HH:MM:SS.SSSSSS] <log message>" (no <>) to ISO-8601: "YY-MM-DDTHH:MM:SS.SSSSSS-0:400"
timezone="05:00"
from_log=$(
	grep -oP '((?<=^\[)(\d{2}-?){3} (\d{2,}[:.]?){4})' doop-log.txt |
		awk -F'[- ]' "{printf(\"%s-%s-%sT%s-%s\n\", \$3, \$2, \$1, \$4, \"$timezone\")}"
)

# convert to unix timestamp
if [[ $1 == "--utc" || $1 == "-u" ]]; then
	for date in $from_log; do
		echo $(date -d "$date" +"%s%N")
	done
else
	echo "$from_log"
fi
