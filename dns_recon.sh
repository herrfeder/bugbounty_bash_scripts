#!/bin/bash

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


# function for manually adding ip's for subdomain results
add_ip () {
	cat $sd/"$1" | sort -u > $sd/temp_domain
	for domain in $( cat $sd/temp_domain ); do
		   ip=$(host $domain |  grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
		   echo "$domain" "$ip" > $sd/"$1"
	done
}


for domain in $sd_source; do
	# passive amass with additional scripts
	amass enum -scripts $DIR/amass_exts/ -passive -d $domain -o $sd/passive_subs_amass_$domain -include assetfinder,subfinder,github-subdomains -config /home/user/tools/configs/amass_config.ini
	
	add_ip "passive_subs_amass_$domain"
	cat $sd/passive_subs_amass_$domain | sort -u | tee -a $sd/all_subs_$domain

	# active amass
	amass enum -active -d $domain $ama_asn $ama_cidr -o $sd/active_subs_amass_$domain -ip -config /home/user/tools/configs/amass_config.ini
	cat $sd/active_subs_amass_$domain | sort -u | tee -a $sd/all_subs_$domain

	# brute amass
	# using https://github.com/assetnote/commonspeak2-wordlists/blob/master/subdomains/subdomains.txt
	# or https://gist.github.com/jhaddix/86a06c5dc309d08580a018c66354a056
	subbrute.py ~/tools/wordlists/subdomains.txt $domain | filter-resolved > $sd/brute_subs_subbrute_$domain
	
	# manually add ip's for brute results
	add_ip "brute_subs_subbrute_$domain"
	cat $sd/brute_subs_subbrute_$domain | sort -u | tee -a $sd/all_subs_$domain

	
	### alternatives for bruteforcing

	#amass enum -brute -w /home/user/tools/wordlists/subdomains.txt -d $1 -o $sd/brute_subs_amass_$domain -ip -config /home/user/tools/configs/amass_config.ini
	
	### really effective but kills provider internet several times
	#subbrute.py ~/tools/wordlists/jhaddix_sub.txt $domain | massdns -r ~/tools/wordlists/resolvers.txt -t A -o S -w $sd/subs_massdns_$domain

	"$DIR"/dns_postprocess.sh $domain
done



