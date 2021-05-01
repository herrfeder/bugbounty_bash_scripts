#!/bin/bash

url=$1
output_dir=$1
if [ ! -z "$output_dir" ]; then
	mkdir $output_dir
fi


wafw00f $url -o "$output_dir"/waf_"$output_dir".json 1&>/dev/null

echo $url | gau | sed "s|^|gau\||" >> "$output_dir"/u_gau_urls_$url

echo $url | waybackurls | sed "s|^|wayback\||" >> "$output_dir"/u_wayback_urls_$url

gospider -s "https://$url" -s "http://$url" -a -r -d 0 | tee >(grep -E "^\[robots\]" | cut -d"-" -f2- | sed "s|^|gospider\||" >> "$output_dir"/u_urls_$url) >(grep -E "^\[url\]" | cut -d"-" -f4- | sed "s|^|gospider\||" >> "$output_dir"/u_urls_$url) >(grep -E "^\[linkfinder\]" | cut -d":" -f2- | cut -d"]" -f1 | sed "s|^|gospider\||" >> "$output_dir"/u_js_$url) >(grep -E "^\[javascript\]" | cut -d"-" -f2- | sed "s|^|gospider\||" >> "$output_dir"/u_js_$url) > /dev/null

cat "$output_dir"/u_gau_urls_$url | sort -u > .temp_url
mv -f .temp_url "$output_dir"/u_gau_urls_$url

cat "$output_dir"/u_wayback_urls_$url | sort -u > .temp_url
mv -f .temp_url "$output_dir"/u_wayback_urls_$url

cat "$output_dir"/u_gau_urls_$url | grep -E "\.js" >> "$output_dir"/u_js_$url
cat "$output_dir"/u_wayback_urls_$url | grep -E "\.js" >> "$output_dir"/u_js_$url

cat "$output_dir"/u_js_$url | sort -u > .temp_url
mv -f .temp_url "$output_dir"/u_js_$url 
