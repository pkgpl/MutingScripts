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

def merger(repolyg, polyg)
	rept=Array.new
	repx=Array.new
	File.open(repolyg,'r').each do |line|
		arr = line.split(' ')
		rept << arr[0].to_f
		repx << arr[1].to_f
	end
	polt=Array.new
	polx=Array.new
	File.open(polyg,'r').each do |line|
		arr = line.split(' ')
		unless repx[0] <= arr[1].to_f and arr[1].to_f <= repx[-1]
			polt << arr[0].to_f
			polx << arr[1].to_f
		end
	end
	f=File.open(polyg,'w')
		0.upto(polx.size-1) do |i|
			if polx[i] < repx[0]
				f.write("#{polt[i]} #{polx[i]}\n")
			end
		end
		0.upto(repx.size-1) do |i|
			f.write("#{rept[i]} #{repx[i]}\n")
		end
		0.upto(polx.size-1) do |i|
			if polx[i] > repx[-1]
				f.write("#{polt[i]} #{polx[i]}\n")
			end
		end
	f.close
	rept.clear ; repx.clear
	polt.clear ; polx.clear
end

def mkdir(dir)
	if not File.exists?(dir)
		system "mkdir #{dir}"
	end
end

MSG= <<END
	Gpl Apply Mute : Apply muting using polygons
	Usage :
		#{File.basename(__FILE__)} first=[] last=[] [optional parameters]
	Required parameters :
		first	: shot number of the first shotgather
		last	: shot number of the last shotgather
	Optional parameters
		step=1		: shot step [do first,last,step]
		ldigit=4	: length of fldr digits [3|4|5|6]
END

error_sa(MSG) if ARGV.size == 0

First=from_param_sa('first').to_i
Last=from_param_sa('last').to_i
Step=from_param_sa('step',1).to_i

idir='./Shot'
odir='./Muteshot'
pdir='./Polygon'
mkdir(odir)
mkdir(pdir)

#filename=from_param_sa('fin',nil)
outfile=from_param_sa('fout','muteshot')
outfile=odir+'/'+outfile
#puts outfile, pdir
#d2=from_param_sa('d2',nil)
#dt=from_param_sa('dt',0.004)
ldigit=from_param_sa('ldigit',4)

ARGV.clear ## to use 'gets' later

## polygon => mute
First.step(Last,Step) do |jj|
	# previous
	pjnum=sprintf("%0#{ldigit}d",jj-Step)
	ppolyg="#{pdir}/polyg.#{pjnum}"

	# current
	jnum=sprintf("%0#{ldigit}d",jj)
	puts "jnum=#{jnum}"
	polyg="#{pdir}/polyg.#{jnum}"

	## current shot gather
	tmpfile=idir+'/Shot.'+jnum+'.su'
	if not File.exists?(tmpfile)
		error_sa("cannot find #{tmpfile}")
	end

	checkagain=true
	muted=false
	curvecolor="red"
	# curvecolor
	# red : for checking
	# green : for normal replace
	# blue : for changing previous picking
	while checkagain

		if File.exists?(polyg)
			if File.size(polyg) > 0
				## make mute parameters
				system "mkparfile < #{polyg} string1=tmute string2=xmute > #{pdir}/par.#{jnum}"
				xpar=`sed <#{pdir}/par.#{jnum} -n 's/xmute=//p'`.chomp
				tpar=`sed <#{pdir}/par.#{jnum} -n 's/tmute=//p'`.chomp

				## muting
				system "sumute < #{tmpfile} key=tracf xmute=#{xpar} tmute=#{tpar} > #{outfile}.#{jnum}"

				## checking
				if not muted
					warn='CAUTION: This is for checking. do not save mouse pick!'
					## find npair
					linecount=0
					File.open(polyg,'r').each do |line|
						linecount+=1
					end
					npair=linecount
					## replace!
					plotcmd=" curve=#{polyg} curvecolor=red npair=#{npair} "
				else
					warn=''
					plotcmd=''
				end
				answer = 'y'
			else
				puts "#{polyg} file size=0, please save mouse pick in suximage"
				puts '(r)edo | (q)uit'
				answer = gets.chomp
				answer='n' if answer == 'r'
			end
		elsif File.exists?(ppolyg) ## copy previous polygon and replace
			system "cp #{ppolyg} #{polyg}"
			curvecolor="blue"
			answer = 'r'
		else ### if polygon file not exists, mute!
			answer = 'n'
		end

		checkagain=false
		curvecolor="red"
	end
end
