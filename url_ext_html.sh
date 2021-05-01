#!/bin/bash


if [ -z "$2" ]; then
	output_dir=html_source
else
	output_dir="$2"
fi

if [ ! -d "$output_dir" ]; then
	mkdir "$output_dir"
fi

export html_output_dir="$output_dir"

function_curl_and_save() {
	origin_url=$1
	filename=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
	
	origin=$(echo "$origin_url" | cut -d"|" -f1)
	url=$(echo "$origin_url" | cut -d"|" -f2-)
	
	if [ ! -z $url ]; then
		curl_resp=$(curl -Ls -m 3 -w "%{http_code}|$origin|$url|%{url_effective}|%{time_redirect}|%{num_redirects}|%{size_download}|%{content_type}|$filename" $url -o "$html_output_dir"/"$filename" )

		echo $curl_resp | tee -a curl_html_resp
		if [[ $curl_resp = 404* ]]; then
			rm "$html_output_dir"/"$filename"
		fi
	fi
}

export -f function_curl_and_save


http_resp=$(curl -k -w "%{http_code}" -s -o /dev/null http://$1 -m 3 )
https_resp=$(curl -k -w "%{http_code}" -s -o /dev/null https://$1 -m 3 )

if [ -f .temp_grep ]; then
	echo -n "" > .temp_grep
fi


if [ $http_resp != "000" ]; then
	cat "$1"/"u_urls_$1" "$1"/"u_gau_urls_$1" "$1"/"u_wayback_urls_$1" | grep "http://$1" >> .temp_grep
fi

if [ $https_resp != "000" ]; then
	cat  "$1"/"u_urls_$1" "$1"/"u_gau_urls_$1" "$1"/"u_wayback_urls_$1" | grep "https://$1" >> .temp_grep

fi

if [ -s .temp_grep ]; then 
	cat .temp_grep | grep -Ev '(.css|.png|.jpeg|.jpg|.svg|.gif|.woff|.js)' | parallel --jobs 10 "read pipe_url; function_curl_and_save $pipe_url"

	fdupes -dN "$html_output_dir"
fi
