# Picking

Efficient manual muting scripts.

0. Setup
	1. Make directories (run `0_mkdir.sh`)
	2. Split fldr-sorted input su file (One shot gather in each su file, use `0_susplit.sh`)
	   Make sure splitted su files have "tracf" keyword and sorted by it.
	3. (Optional) Sort by offset for 3D shot gathers (run `sort_offset.sh` in `./Shot`)
1. **Mute** (skip shots, run `1_mute.rb`)
2. **Interpolate** skipped polygons (run `2_interp.rb`)
3. **Apply** muting to skipped shots using the interpolated polygons (run `3_apply.rb`)
4. (Optional) Sort back to original order for 3D shot gathers
5. Merge muted shot gathers (`./Muteshot/muteshot.*`)



## Mute

	Gpl Mute : Mute shotgathers
	Usage :
		1_mute.rb first=[] last=[] [optional parameters]
	Required parameters :
		first	: shot number of the first shotgather
		last	: shot number of the last shotgather
	Optional parameters
		step=1		: shot step [do first,last,step]
		perc=85		: suximage percent
		hbox=1000	: suximage hbox
		wbox=1270	: suximage wbox
		x1end		: suximage x1end
		d2=1		: suximage d2
		ldigit=4	: length of fldr digits [3|4|5|6]

## Interpolate

Use the same `first`, `last`, and `step` used in Mute step.

	Gpl Mute Interpolator : read polygon files and interpolate skipped polygons
	Usage :
		2_interp.rb first=[] last=[] [optional parameters]
	Required parameters :
		first	: shot number of the first shotgather
		last	: shot number of the last shotgather
	Optional parameter :
		step=last-first	: shot step
		ldigit=4	: length of fldr digits [3|4|5|6]

## Apply

Use the same `first` and `last` used in Mute step. (`step`= increments of the fldr numbers)

	Gpl Apply Mute : Apply muting using polygons
	Usage :
		3_apply.rb first=[] last=[] [optional parameters]
	Required parameters :
		first	: shot number of the first shotgather
		last	: shot number of the last shotgather
	Optional parameters
		step=1		: shot step [do first,last,step]
		ldigit=4	: length of fldr digits [3|4|5|6]


## Reference

Kim, A., D. Ryu, W. Ha, C. Shin, 2015, [An efficient first arrival picking procedure for marine streamer data](http://www.tandfonline.com/doi/full/10.1080/12269328.2015.1047965#.VYy3kGAVd0c), Geosystem Engineering, Published Online.
