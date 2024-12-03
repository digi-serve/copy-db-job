#write out current crontab
crontab -l > mycronlist

#echo new cron into cron file
echo "$CRON_EXPRESSION sh /app/db_transfer.sh" >> mycronlist

#install new cron file
crontab mycronlist

rm mycronlist
