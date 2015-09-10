#!/bin/bash
# Script name :

for file in muteshot.??????
do
	echo $file
	bak=${file}.bak
	mv $file $bak
	susort +ep < $bak > $file
done
