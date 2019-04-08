#!/bin/bash

url="http://www.europarl.europa.eu/meps/en/full-list/xml"

wget $url
xml2csv --input xml --output csv --tag mep

echo "$(head -n1 csv),email" > emails;

list=$(tail -n $(($(cat csv|wc -l) - 1)) csv)
while read -r line; do
	id=$(echo "$line"|cut -d\" -f8)
	email=$(wget "http://www.europarl.europa.eu/meps/en/$id" -o /dev/null -O -|grep mailto|cut -d: -f2-|rev|sed 's/\]ta\[/@/g'|sed 's/\]tod\[/\./g'|head -n 1|cut -d\" -f8)
	#echo "$email"
	echo "$line,\"$email\"" >> emails
done <<< "$list"

# cleanup
rm xml csv
