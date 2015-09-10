#!/usr/bin/ruby -w
#
# puts 'str' to stderr and stop the program
def error_sa(str) # stand alone error
	File.open(2,"w") {|f| f.write(str+"\n")}
	exit 1
end

# find 'str=val' among command line parameters and return 'val'
# if default value is not given, call error_sa when 'str=val' is not found among command line parameters
def from_param_sa(str,*default) ## stand alone from_param
	ARGV.each do |arg|
		if arg =~ /#{str}=.+/
			b=arg.split("=")
			return b[1]
		end
	end
	error_sa("cannot read parameter : #{str}") if default.size==0
	return default[0]
end

MSG= <<END
	Gpl Mute Interpolator : read polyg.#### files and interpolate skipped polygons
	Usage :
		#{File.basename(__FILE__)} first=[] last=[] step=[]
	Required parameters :
		first	: shot number of the first shotgather
		last	: shot number of the last shotgather
	Optional parameter :
		step=last-first	: shot step
		ldigit=4	: length of fldr digits [3|4|5|6]
END
error_sa(MSG) if ARGV.size == 0

#First=2379
#Last=2381
#Step=2
First=from_param_sa('first').to_i
Last=from_param_sa('last').to_i
Step=from_param_sa('step',Last-First).to_i
ldigit=from_param_sa('ldigit',4)

# get min. tracf
#tracfmin=Hash.new
#File.open('tracf.min','r').each do |line|
#	key,val=line.split(' ')
#	tracfmin[key.to_i]=val.to_i
#end

# initialize
x=1 # for index in dat1 and dat2
t=0 # for index in dat1 and dat2

pdir='./Polygon/'

First.step(Last-1,Step) do |inum|
	puts "between polyg.#{sprintf("%0#{ldigit}d",inum)} and polyg.#{sprintf("%0#{ldigit}d",inum+Step)}"

	# initialize
	dat1t=Array.new ; dat1x=Array.new
	dat2t=Array.new ; dat2x=Array.new
	xindex=Array.new

	# read polygon data1
	File.open(pdir+"polyg.#{sprintf("%0#{ldigit}d",inum)}",'r').each do |line| 
		dat1t << line.split(' ')[t].to_f
		dat1x << line.split(' ')[x].to_f - 1 #tracfmin[inum]
	end
	# sort data by x
	
#	# remove reversed data
#	del=nil
#	0.upto(dat1x.size-2) {|i| del=i if dat1x[i] > dat1x[i+1]}
#	if del
#		0.upto(del) do
#			dat1x.shift
#			dat1t.shift
#		end
#		puts dat1x,dat1t
#	end

	# read polygon data2
	File.open(pdir+"polyg.#{sprintf("%0#{ldigit}d",inum+Step)}",'r').each do |line|
	        dat2t << line.split(' ')[t].to_f
	        dat2x << line.split(' ')[x].to_f - 1 #tracfmin[inum+Step]
	end
	# sort data by x
	
#	# remove reversed data
#	del=nil
#	0.upto(dat2x.size-2) {|i| del=i if dat2x[i] > dat2x[i+1]}
#	if del
#		0.upto(del) do
#			dat2x.shift
#			dat2t.shift
#		end
#		puts dat2x,dat2t
#	end

	# make xindex including dat1x and dat2x
	dat1x.each {|e| xindex << e }
	dat2x.each {|e| xindex << e }

	xindex.sort! # sort
	xindex.shift # remove first x
	xindex.pop   # remove last x
	xindex.uniq! #if xindex.uniq

	# self-interpolation of polygs at x positions in xindex
	n1t=Array.new
	n2t=Array.new

	xindex.each do |ix|
		if dat1x.include?(ix)
			n1t << dat1t[dat1x.index(ix)]
			#print ix,' ', dat1t[dat1x.index(ix)], " 1y\n"
		else
			arrtmp=Array.new
			dat1x.each { |e| arrtmp << e if e < ix }
			low = arrtmp.max
			arrtmp.clear
			dat1x.each { |e| arrtmp << e if e > ix }
			up = arrtmp.min

			lid=dat1x.index(low)
			uid=dat1x.index(up)
			#unless lid and uid
			#	puts "ix=#{ix}"
			#	puts "low,up=#{low},#{up}"
			#	puts "lid,uid=#{lid},#{uid}"
			#	puts 'error #1'
			#	exit 1
			#end

			if lid and uid
				intp = (up-ix)*dat1t[lid] + (ix-low)*dat1t[uid]
				intp /= (up-low)
			elsif lid
				intp = dat1t[lid]
			elsif uid
				intp = dat1t[uid]
			else
				puts "interpolation error #1"
				exit 1	
			end

			n1t << intp
			#print ix,' ', intp, " 1n\n"
		end

		if dat2x.include?(ix)
			n2t << dat2t[dat2x.index(ix)]
			#print ix,' ', dat2t[dat2x.index(ix)], " 2y\n"
		else
			arrtmp=Array.new
			dat2x.each { |e| arrtmp << e if e < ix }
			low = arrtmp.max
			arrtmp.clear
			dat2x.each { |e| arrtmp << e if e > ix }
			up = arrtmp.min

			#print 'ix=',ix,' low=',low,' up=',up,"\n"
			lid=dat2x.index(low)
			uid=dat2x.index(up)
			#unless lid and uid
			#	puts "ix=#{ix}"
			#	puts "low,up=#{low},#{up}"
			#	puts "lid,uid=#{lid},#{uid}"
			#	puts 'error #2'
			#	exit 1
			#end

			if lid and uid
				intp = (up-ix)*dat2t[lid] + (ix-low)*dat2t[uid]
				intp /= (up-low)
			elsif lid
				intp = dat2t[lid]
			elsif uid
				intp = dat2t[uid]
			else
				puts "interpolation error #2"
				exit 1
			end
			n2t << intp
			#print ix,' ', intp, " 2n\n"
		end
	end

	### interpolation between the two known curves
	min=inum
	max=inum+Step
	(min+1).step(max-1,1) do |jj|
		jnum=sprintf("%0#{ldigit}d",jj)
		puts "jnum=#{jnum}"
		lweight=(max-jj).to_f/Step.to_f
		rweight=(jj-min).to_f/Step.to_f

		interpolated=Array.new
		k=0
		xindex.each do |ix|
			interpolated << lweight*n1t[k]+rweight*n2t[k]
			k+=1
		end

		File.open(pdir+"polyg.#{jnum}",'w') do |f|
			0.upto(xindex.size-1) do |i|
				#f.write("#{interpolated[i]} #{xindex[i]+tracfmin[jj]}\n")
				f.write("#{interpolated[i]} #{xindex[i]+1}\n")
			end
		end
	end

	# clear
	dat1t.clear ; dat1x.clear
	dat2t.clear ; dat2x.clear
end
