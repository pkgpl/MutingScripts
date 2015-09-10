# Picking

Efficient manual muting scripts.

0. Setup
	1. Make directories (run 0_mkdir.sh)
	2. Split fldr-sorted input su file (use 0_susplit.sh)
	3. Sort by offset for 3D shot gathers (run sort_offset.sh in ./Shot)
1. Mute (skip shots)
2. Interpolate skipped polygons
3. Apply muting to skipped shots using interpolated polygons


Kim, A., D. Ryu, W. Ha, C. Shin, 2015, [An efficient first arrival picking procedure for marine streamer data](http://www.tandfonline.com/doi/full/10.1080/12269328.2015.1047965#.VYy3kGAVd0c), Geosystem Engineering, Published Online.