#!/bin/bash
. ~/bash/utility.sh

spe(){
	setParseEnvironment $@
}

pc(){
	parseCommand $@
}

setParseEnvironment(){
	if [ $1 == 'terrortorch' ] ; then
		parseappid='93L9AEs5A7syGYf8xNB3NlGQfN3dtzoQfg5UnG1k'
		parserestkey='D1iLSP7sf0QH2C17ZWZylnG4Q5Dw1YjQw5tAVGrH'
		echo 'TerrorTorch environment set'
	fi
}


parseCommand(){
	JSON ${@:2:$(($#-1))};
	echo 'Sending data: '$json
	curl -X POST \
	-H "X-Parse-Application-Id: $parseappid" \
	-H "X-Parse-REST-API-Key: $parserestkey" \
	-H "Content-Type: application/json" \
	-d  $json \
	https://api.parse.com/1/functions/$1
	printf '\n'
}