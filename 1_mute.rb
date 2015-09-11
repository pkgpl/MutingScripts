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
	Gpl Mute : Mute shotgathers
	Usage :
		#{File.basename(__FILE__)} first=[] last=[] [optional parameters]
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
perc=from_param_sa('perc',85)
height=from_param_sa('hbox',1000)
width=from_param_sa('wbox',1270)
x1end=from_param_sa('x1end',nil)
d2=from_param_sa('d2',nil)
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
	repl=true
	while checkagain

		if File.exists?(polyg)
		    if repl
			repl=nil
			answer='r'
			curvecolor='green'
		    else
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
				command= "suximage < #{outfile}.#{jnum} perc=#{perc} title=#{jnum} key=tracf wbox=#{width} hbox=#{height} xbox=0 ybox=0 label2='#{warn}' d1=0.004 f2=1 d2=#{d2}" 
				command+=" x1end=#{x1end}" if x1end
				command+=plotcmd
				#puts command
				system command

				puts 'ok? [ (y)es or enter | (r)eplace | (n)ot good | (q)uit ]'
				answer = gets.chomp
				curvecolor='green' if answer == 'r'
			else
				puts "#{polyg} file size=0, please save mouse pick in suximage"
				puts '(r)edo | (q)uit'
				answer = gets.chomp
				answer='n' if answer == 'r'
			end
		    end # repl
		elsif File.exists?(ppolyg) ## copy previous polygon and replace
			system "cp #{ppolyg} #{polyg}"
			curvecolor="blue"
			answer = 'r'
		else ### if polygon file not exists, mute!
			answer = 'n'
		end

		case answer
		when '', 'y'

			## good
			checkagain=false

		when 'r'

			## find npair
			linecount=0
			File.open(polyg,'r').each do |line|
				linecount+=1
			end
			npair=linecount

			## replace!
			repolyg="repolyg.#{jnum}"
			command= "suximage < #{tmpfile} perc=#{perc} mpicks=#{repolyg} key=tracf wbox=#{width} hbox=#{height}  d1=0.004 f2=1 d2=#{d2} label2='replace'"
		       	command+=" xbox=0 ybox=0 title=#{jnum} curve=#{polyg} curvecolor=#{curvecolor} npair=#{npair} "
			command+=" x1end=#{x1end}" if x1end
			system command

			#error_sa(repolyg+" file size == 0") if File.size(repolyg) == 0

			### merge repolyg.#### to polyg.####
			#merger(repolyg, polyg)
			#system "rm #{repolyg} &"
			if File.size(repolyg) > 0
				## merge repolyg.#### to polyg.####
				merger(repolyg, polyg)
				system "rm #{repolyg} &"
			else
				system "rm #{repolyg} &"
			end

		when 'q'
			exit 1

		else

			## not good, redo! 
			command= "suximage < #{tmpfile} perc=#{perc} mpicks=#{polyg} key=tracf wbox=#{width} hbox=#{height} d1=0.004 f2=1 d2=#{d2}"
			command+=" xbox=0 ybox=0 title=#{jnum} "
			command+=" x1end=#{x1end}" if x1end
			system command
			muted=true
		end

		curvecolor="red"
	end
end
