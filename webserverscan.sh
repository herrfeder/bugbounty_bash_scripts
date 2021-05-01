#!/bin/bash


sd=webscanner
if [ -d "$sd" ]; then
	echo "Webscanner Directory exists"     
else                                     
	mkdir $sd                           
fi

if [ -f "$1" ]; then       
	# it needs to remove quotes for not interpreting new lines as single strings
	sd_source=$(cat $1)             
else 
        sd_source="$1"                           
fi


for domain in $sd_source; do
	domain_fn=$(echo $domain | cut -d"/" -f3-)

	jaeles scan -G -c 3 \
		-s '~/tools/signatures/jaeles-signatures/' \
		-u $domain \
		-o "$sd"/jaeles_"$domain_fn"

	echo "$domain" | nuclei -rl 20 -c 3 -silent \
		-t ~/tools/signatures/nuclei-templates/ \
	       	-o "$sd"/nuclei_"$domain_fn"	
done
