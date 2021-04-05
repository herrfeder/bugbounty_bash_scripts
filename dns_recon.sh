#!/bin/bash

pwd

sd=subdomains
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -d "$sd" ]; then
	echo "Subdomains Directory exists"
else
	mkdir $sd
fi


if [ -f "$1" ]; then
	sd_source=$(cat $1)
else
	sd_source=$1
fi


if [ ! -z "$2" ]; then
	ama_asn="-asn $2"
fi

if [ ! -z "$3" ]; then
	ama_cidr="-cidr $3"
fi


for domain in $sd_source; do
	# passive amass with additional scripts
	amass enum -scripts $DIR/amass_exts/ -passive -d $domain -o $sd/passive_subs_amass_$domain -include assetfinder,subfinder,github-subdomains -config /home/user/tools/configs/amass_config.ini
	#cat $sd/passive_subs_amass_$domain | sort -u | tee -a $sd/all_subs_$domain

	# active amass
	amass enum -active -d $domain $ama_asn $ama_cidr -o $sd/active_subs_amass_$domain -ip -config /home/user/tools/configs/amass_config.ini
	cat $sd/active_subs_amass_$domain | sort -u | tee -a $sd/all_subs_$domain

	# brute amass
	# using https://github.com/assetnote/commonspeak2-wordlists/blob/master/subdomains/subdomains.txt
	amass enum -brute -w /home/user/tools/wordlists/subdomains.txt -d $1 -o $sd/brute_subs_amass_$domain -ip -config /home/user/tools/configs/amass_config.ini
	cat $sd/brute_subs_amass_$domain | sort -u | tee -a $sd/all_subs_$domain

	#subbrute.py ~/tools/wordlists/jhaddix_sub.txt $domain | massdns -r ~/tools/wordlists/resolvers.txt -t A -o S -w $sd/subs_massdns_$domain
	#cat $sd/subs_massdns_$domain | cut -d" " -f1 | tee -a $sd/all_subs_$domain

	#sort -u $sd/all_subs_$domain -o $sd/all_subs_$domain
	#cat $sd/all_subs_$domain | filter-resolved | tee -a $sd/sa_all_subs_$domain

done


