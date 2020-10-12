#!/bin/bash

sd="subdomains"

for domain in $(cat $1); do
	dns_recon.sh $domain
done


TIMESTAMP=`date "+%Y-%m-%d"`
cat $sd/sa_all_subs_active_* | sed 's/\.$//' | sort -u > subs_active_$TIMESTAMP



# Grab Params and URLs

for domain in $(cat subs_active_* | sort -u); do
	echo "Grab URLs for $domain"
	grab_urls.sh "$domain"
	echo "Extract JS"
	ext_par_js.sh "$domain"
	echo "Extract URL param"
	ext_par_url.sh "$domain"
	echo "Extract HTML param"
	ext_par_html.sh "$domain"

done

# Grab Directories

for domain in $(cat subs_active_* | sort -u); do
	dir_trav.sh $domain
done
