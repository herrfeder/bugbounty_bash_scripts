#!/bin/bash

sd="subdomains"

dns_recon.sh $1

# Grab Params and URLs

for domain in $(cat $sd/all_resolved_domains); do
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


