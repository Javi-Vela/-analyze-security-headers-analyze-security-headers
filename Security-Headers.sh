#!/bin/bash

read -p "enter a URL: " url
temporaly=temporary.txt
curl -I $url > $temporaly
j=0
warning=(0 1 1 1 1 1 0)
field=(x-frame-option strict-transport-security access-control-allow-origin content-security-policy x-xss-protection
x-content-type-options x-powered-by)

while read linea; do
	line2=`echo $linea | cut -d ":" -f1`
	if [ "$line2" = "x-frame-option" ]; then
		option=`echo $line2 | cut -d ":" -f2`
		if [ "$option"="deny" ] || [ "$option"="sameorigin" ]; then
			warning[0]=1 
		fi

	elif [ "$line2" = "strict-transport-security" ]; then
		warning[1]=0

	elif [ "$line2" = "access-control-allow-origin" ]; then
		warning[2]=0

	elif [ "$line2" = "content-security-policy" ]; then
		warning[3]=0

	elif [ "$line2" = "x-xss-protection" ]; then
		option=`echo $line | cut -d ":" -f2`
		if [ "$option"="1" ] || [ "$option"="1; mode=block" ]; then
			warning[4]=0
		fi

	elif [ "$line2" = "x-content-type-options" ]; then
		option=`echo $line | cut -d ":" -f2`
		if [ "$option"="nosniff" ]; then
			warning[5]=0
		fi

	elif [ "$line2" = "x-powered-by" ]; then
		warning[6]=1
	fi

done < $temporaly

for ((i=0; i<=6; i++)); do
	if [ ${warning[$i]} = 1 ]; then
		echo "WARNING\n Incorrect value for "${field[$i]}
	else
		echo "Correct value for "${field[$i]}
	fi
	echo " "
done

rm $temporaly
