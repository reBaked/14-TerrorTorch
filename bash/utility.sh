JSON(){

json='{'
i=1

if [ $(( $# % 2 )) == 1 ] ; then
	echo "Only JSON even parameters"
else 

	for arg in ${*}; do

		if [ $arg == 'true' ] ; then
			json=$json'true'
		elif [ $arg == 'false' ] ; then
			json=$json'false'
		elif [ "$arg" -eq "$arg" ] 2>/dev/null; then
			json=$json$arg
		else
			json=$json\"$arg\"
		fi

		if [ $(( i % 2 )) == 0 ] ; then
			json=$json,
		else
			json=$json:
		fi

		i=$(( i + 1 ))
	done

	if [ $# != 0 ] ; then
		json=${json%?}
	fi

	json=$json'}'
fi
}