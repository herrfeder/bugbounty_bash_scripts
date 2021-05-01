#!/bin/bash

# Grab Params and URLs

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

vp=vars_pars

if [ ! -d "$vp" ]; then
	mkdir "$vp"
fi

for domain in $(cat $1); do
	echo "Grab URLs for $domain"
	"$DIR"/url_grab.sh "$domain"
	echo "Extract JS"
	"$DIR"/url_ext_js.sh "$domain"
	echo "Extract URL param"
	"$DIR"/url_ext_link.sh "$domain"
	echo "Extract HTML param"
	"$DIR"/url_html.sh "$domain"

done


