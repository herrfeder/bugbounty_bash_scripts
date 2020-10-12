
# Grab Params and URLs


vp=vars_pars

if [ ! -d "$vp" ]; then
	mkdir "$vp"
fi

for domain in $(cat $1); do
	echo "Grab URLs for $domain"
	grab_urls.sh "$domain"
	echo "Extract JS"
	ext_par_js.sh "$domain"
	echo "Extract URL param"
	ext_par_url.sh "$domain"
	echo "Extract HTML param"
	ext_par_html.sh "$domain"

done


