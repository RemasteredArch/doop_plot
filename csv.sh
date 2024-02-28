#! /bin/env bash

input_file="$1"

timezone="-05:00"
use_iso=0
if [[ $1 == "-i" || $1 == "--iso-8601" ]]; then
	input_file="$2"
	use_iso=1
else
	input_file="$1"
	use_iso=0
fi

if [[ $input_file == "" ]]; then
	echo "No file given!"
	exit 1
fi

output_file="$input_file.csv"
echo "" > "$output_file"

while read -r line; do
	# converts timestamp from "[DD-MM-YY HH:MM:SS.SSSSSS] <log message>" (no <>) to ISO-8601: "YY-MM-DDTHH:MM:SS.SSSSSS-0:400"
	date=$(
	echo "$line" |
		grep -oP '((?<=^\[)(\d{2}-?){3} (\d{2,}[:.]?){4})' |
		awk -F'[- ]' "{printf(\"%s-%s-%sT%s%s\n\", \$3, \$2, \$1, \$4, \"$timezone\")}"
	)
	if [[ $use_iso != 1 ]]; then # convert to unix timestamp
		date=$(date -d "$date" +"%s") # set to +"%s%N" for nanosecond precision
	fi

	type=$(echo "$line" | grep -oP '(?<=\()[a-z]+')
	text=$(echo "$line" | grep -oP '(?<=\) )[^:]+')

	echo "$date,$type,$text" >> "$output_file"
done < "$input_file"
