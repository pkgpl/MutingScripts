#!/bin/bash
# Script name :

for file in Shot.??????.su
do
	echo $file
	org=${file}.org
	tmp=${file}.tmp
	mv $file $org
	sushw key=ep,f1,f2,d1,d2 a=1,0,0,0,0 b=1,0,0,0,0 < $org > $tmp
       	susort +offset < $tmp | sushw key=tracf a=1 b=1 > $file
	rm $tmp
done
