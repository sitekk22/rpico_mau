#!/bin/bash
help_triggered=false

quit(){
	kill $$
	exit
}
trap quit SIGINT

if [[ "$1" == "-h" || "$1" == "--help" ||  -z "$1" ]]; then
	help_triggered=true
	echo "  First arugment- build directory path"
	echo "  Second argument- project name"
	echo "  Third argument- Raspberry Pi Pico path"
	quit
fi


if ! [ -d $1 ]; then
	echo "$1 is not valid directory"
	quit		
fi


if [[ -z $2  && "$help_triggered" != true ]]; then
	echo "Specify project name as second command line argument"
	quit
fi


if [ -z $3 ] && [ "$help_triggered" != true ]; then
	echo "Specify Raspberry Pi path as third command line argument"
	quit
fi

make -s -C "$1" 2>/tmp/make.log
cat /tmp/make.log

if ! [ -f "$1$2.uf2" ]; then
	echo "Errors occured"
	quit
fi 

upload_file(){
	
	if ! [[ -a "$1$2.uf2" ]]; then
		echo "$2 is not valid project name, make sure it's name without .uf2"
		quit
	fi
	
	if [ -d $3 ]; then
		echo -e "\nUPLOADING"
	fi 
	
	cp "$1$2.uf2" $3 2>/dev/null

}


echo -e "\nEnter bootloader on RPI\nPress CTRL+C to exit"
until upload_file "$1" "$2" "$3"
do    
    upload_file "$1" "$2" "$3"
    
    sleep 0.1
done
rm $1$2.*
echo "DONE"
quit


