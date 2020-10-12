#!/bin/bash

ud="urls"

delay=500

domain=$(echo $1 | cut -d"/" -f1)

check_request=$(curl -k -s -I https://$domain/cdn-cgi/)

if [ ! -z "$check_request" ]; then
	echo "Domain is hosted on Cloudflare"
	delay=20000
fi

gobuster dir -u https://$1 --insecuressl --wildcard -l -x ".php,.txt,.yml,.html" -a "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36" -s "200,204,301,302,307,400,401,403,500,502,503,504,900,901" -w ~/wordlists/jhaddix_sub.txt --delay "$delay"ms -o $ud/$1/$1_gobuster

