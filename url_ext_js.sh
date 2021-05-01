#!/bin/bash

vp=vars_pars

if [ -z "$2" ]; then
	output_dir=js_source
else
	output_dir="$2"
fi


if [ ! -d "$output_dir" ]; then
	mkdir "$output_dir"
fi

export js_output_dir=$output_dir

function_curl_js_extract() {
	origin_url=$1
	filename=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
	
	temp_js=.$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
	
	origin=$(echo "$origin_url" | cut -d"|" -f1)
	url=$(echo "$origin_url" | cut -d "|" -f2-)


	curl_resp=$(curl -Ls -m 3 -w "%{http_code}|$origin|$url|%{url_effective}|%{time_redirect}|%{num_redirects}|%{size_download}|%{content_type}|$filename" $url -o "$js_output_dir"/"$filename" )

	echo $curl_resp | tee -a curl_js_resp
	if [[ $curl_resp = 404* ]]; then
		rm "$js_output_dir"/"$filename"
	else

		# UN GZIP FILE
		if [[ "$(file $js_output_dir/$filename)" == *"gzip compressed data"* ]]; then
			cat "$js_output_dir"/"$filename" | gzip -d -c > "$filename"
			mv -f "$filename" "$js_output_dir"/"$filename"
		fi
		# BEAUTIFY OBFUSCATED JS SOURCE
		
		js-beautify "$js_output_dir"/"$filename" > "$temp_js"
		mv -f "$temp_js" "$js_output_dir"/"$filename"

		### GREPPING AND REGEXING JS SOURCE
		# FIND VARIABLES
		cat "$js_output_dir"/"$filename" | grep -Eo "var [a-zA-Z0-9_]+" | cut -d" " -f2 | sort -u | sed "s|^|$url\||" >> .js_vars_temp

		# FIND URL PARAMS
		cat "$js_output_dir"/"$filename" | grep -Eo "(?:\?|&)[a-zA-Z0-9_]{2,}=([^&|;]+)" | grep -Ev "^&&" | grep -Ev "^;" | cut -d"=" -f1 | cut -d"&" -f2 | sort -u | sed "s|^|$url\||" >> .js_params_temp
	
	fi
	
}

export -f function_curl_js_extract

### MAIN FUNCTION

http_resp=$(curl -k -w "%{http_code}" -s -o /dev/null http://$1 -m 3 )
https_resp=$(curl -k -w "%{http_code}" -s -o /dev/null https://$1 -m 3 )

if [ -f .temp_grep ]; then
	echo -n "" > .temp_grep
fi

if [ $http_resp != "000" ]; then
	cat "$1"/"u_js_$1" | grep "http://$1" >> .temp_grep
fi

if [ $https_resp != "000" ]; then
	cat "$1"/"u_js_$1" | grep "https://$1" >> .temp_grep

fi

if [ -s .temp_grep ]; then
	cat .temp_grep | grep -Ev '(.css|.png|.jpeg|.jpg|.svg|.gif|.woff)' | parallel -j10 "read pipe_url; function_curl_js_extract $pipe_url"


	fdupes -dN "$js_output_dir"

	if [ -f .js_vars_temp ]; then
		cat .js_vars_temp | sort -u >> "$vp"/js_vars
		rm .js_vars_temp
	fi
	if [ -f .js_params_temp ]; then
		cat .js_params_temp | sort -u >> "$vp"/js_params
		rm .js_params_temp
	fi
fi

