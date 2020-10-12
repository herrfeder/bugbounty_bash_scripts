#!/bin/bash

sd=subdomains

for domain in $(cat $1); do
	amass enum -d $domain -active -asn 44404 -cidr 185.150.244.0/22 -o $sd/all_subs_$domain
	assetfinder --subs-only $domain | tee -a $sd/all_subs_$domain

	subfinder -d $domain -o $sd/subs_subfinder_$domain
	cat $sd/subs_subfinder_$domain | tee -a $sd/all_subs_$domain

	subbrute.py ~/wordlists/jhaddix_sub.txt $domain | massdns -r ~/wordlists/resolvers.txt -t A -o S -w $sd/subs_massdns_$domain

	cat $sd/subs_massdns_$domain | cut -d" " -f1 | tee -a $sd/all_subs_$domain

	sort -u $sd/all_subs_$domain -o $sd/all_subs_$domain
	cat $sd/all_subs_$domain | filter-resolved | tee -a $sd/sa_all_subs_$domain

done
