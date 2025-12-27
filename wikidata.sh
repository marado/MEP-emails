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
	email=$(echo "$wd"|grep binding\ name=\'email\' -A1|tail -1); # FIXME: we should not assume there's only one email address!
	echo "$id,$qid,$email" >> $filename;
	sleep 1; # let's not hammer WD!
done
echo "$filename now has a CSV with the wikidata items for the MEPs we know the email addresses of, and the addresses they have there. If they don't have one, we might want to populate it outselves..."

# this will give us a CSV with the MEPs that already have an email address in WD so we can compare the one we know with the one that's in there
# note that we are showing only one of the WD mails but there might be more... we might want to validate these entries manually, only use quickstatements for those without any email addresses on WD
withmail=$(cat wd.csv |grep -v ,$|grep -v ^id);
for i in $(seq 1 $(echo "$withmail"|wc -l)); do
	mepid=$(echo "$withmail" |head -n $i |tail -n 1|cut -d, -f1);
	wdemail=$(echo "$withmail" |head -n $i |tail -n 1|cut -d: -f2|cut -d\< -f1);
	euemail=$(grep \"$mepid\" emails|cut -d, -f6);
	echo "$mepid,$euemail,$wdemail";
done
