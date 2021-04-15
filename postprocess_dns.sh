#!/bin/bash

folder="$1"
sd="subdomains"


# processing all domains
cat $sd/all_subs_$1 | sort -u > $sd/all_domain_ip_$1

# extract all resolved subdomains with ips

cat $sd/all_domain_ip_$1 | cut -d ' ' -f1 | filter-resolved > $sd/all_resolved_$1

# extract ips
ips=$(cat $sd/all_domain_ip_$1 | sort -u | cut -d ' ' -f2)
echo $ips | tr "," " " | tr " " "\n" | sort -u > $sd/all_ips_$1

# extract http webserver
cat $sd/all_domain_ip_$1 | cut -d ' ' -f1 | sort -u | httpx > $sd/all_webserver_$1
