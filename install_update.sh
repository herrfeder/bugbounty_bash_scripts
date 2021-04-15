#!/bin/bash


# install tools

## nuclei
go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
cp ~/go/bin/nuclei ~/tools/go/bin/

## jaeles
go get github.com/jaeles-project/jaeles
cp ~/go/bin/jaeles ~/tools/go/bin/


rm -rf ~/go

# update templates/signatures

## set path for nuclei template update
sed 's/#update-directory.*/update-directory: \/home\/user\/tools\/signatures\/nuclei-templates/' ~/.config/nuclei/config.yaml
nuclei -update-templates


## adding jaeles signatures
git clone --depth=1 https://github.com/jaeles-project/jaeles-signatures /tmp/jaeles-signatures/
git clone https://github.com/ghsec/ghsec-jaeles-signatures.git /tmp/ghsec-jaeles-signatures/ && mv /tmp/ghsec-jaeles-signatures /tmp/jaeles-signatures/
mv /tmp/jaeles-signatures/ /home/user/tools/signatures/jaeles-signatures
