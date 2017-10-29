#!/bin/bash

# change this to the URL of the committee you want to get e-mail addresses for
url="http://www.europarl.europa.eu/meps/en/full-list.html?filter=all&leg="

DEBUG=false

# get the pages
rm -rf debug *html
wget "$url" -o /dev/null -O "meps.html";

# get the MEP page URLs
grep  href=\"/meps meps.html |grep _home|grep -v \>|cut -d\" -f2 > meps-urls

# get the MEP pages
if [ "$DEBUG" != true ]; then
	rm *html
else
	mkdir debug; mv *html debug
fi
for m in $(cat meps-urls); do
	wget "http://www.europarl.europa.eu$m" -o /dev/null;
done

# get the email addresses from the MEP pages
echo "e-mail;Country" > emails;
for i in *html; do
	email=$(grep mailto $i|cut -d\" -f2|cut -d: -f2-|rev|sed 's/\]ta\[/@/g'|sed 's/\]tod\[/\./g'|head -n 1);
	country=$(grep nationality $i|cut -d\> -f2);
	echo "$email;$country" >> emails;
done;

# cleanup
if [ "$DEBUG" != true ]; then
	rm *html
fi
