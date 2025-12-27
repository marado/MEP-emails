# this script is meant to be run after `get-mails.sh`, ie, when all the email
# addresses were fetched and we have an `emails` file.
filename="wd.csv"
echo "id,QID,email as seen in wikidata" > $filename;
# for id in $(cat emails |cut -d\" -f8|grep -v id|head -n 2); do # DEBUG with just 2 lines
for id in $(cat emails |cut -d\" -f8|grep -v id); do
	# 'id' is the MEP id of a MEP for which we know their e-mail address
	query='SELECT ?mep ?email WHERE {?mep wdt:P1186 "'$id'". OPTIONAL{?mep wdt:P968 ?email}}';
	wd=$(echo "$query" | ./query-wikidata.sh);
	qid=$(echo "$wd"|grep binding\ name=\'mep\' -A1|tail -1|cut -d/ -f5|cut -d\< -f1);
	email=$(echo "$wd"|grep binding\ name=\'email\' -A1|tail -1);
	echo "$id,$qid,$email" >> $filename;
	sleep 1; # let's not hammer WD!
done
echo "$filename now has a CSV with the wikidata items for the MEPs we know the email addresses of, and the addresses they have there. If they don't have one, we might want to populate it outselves..."
