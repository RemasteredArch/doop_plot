# config
script_title = "Doop Log"
input_data = "doop-log.txt.csv"
ytics = "(1, 3, 5, 10, 15, 20)"

parent_script = "plot\\_log.sh"
summary_interval = 60 * 60 * 24 # one day in seconds
summary_interval_title = "logs per day" # what's used in the key
window_width = 1200
window_height = 900
default_font = "sans,12" # changing this is likely to break formatting

set term wxt title script_title size window_width,window_height font default_font
# set term pngcairo size window_width,window_height font default_font

# time stuff
set datafile separator comma
set xdata time
set timefmt "%s" # set format for input time to be unix time in seconds
set xtics timedate
set xtics format "%m/%d/%y"

# making the axes pretty
set tics nomirror
set tics out
set tics scale 2
set xlabel "Date"
set ylabel "Occurences"
set grid
set border 3 # sets the left and bottom sides, unsets the top and right sides
set rmargin 5 # padding to stop overhang

set ytics @ytics
set ytics add autofreq 10

# key stuff
set key above right
set key title "\n" # padding
# also note that the graph title is implemented as a keyentry in the plot call

# graphs
set linetype 1 linecolor "gray" linewidth 2 # total
set linetype 2 linecolor "blue" linewidth 2 # info
set linetype 3 linecolor "green" linewidth 2 # warn
set linetype 4 linecolor "red" linewidth 2 # error
set linetype 5 linecolor "black" linewidth 2 # running average
set style fill transparent solid 0.5 border # fill with 25% opacity and a border

bin(x) = summary_interval * floor(timecolumn(x) / summary_interval)
bin_x = "(bin(1))"

# plots the frequency of occurences over `summary_interval` seconds
# some boxes are wider because they expand to fill places where there are no entries
# good styles: boxes, impulses, histep, fillsteps
plot sum = 0, y = 0, prev_day = 0, max = 0, bin = 0 \
	input_data using (bin(1)):(1) \
		smooth frequency with fillsteps \
		title sprintf("Total %s", summary_interval_title) ls 1, \
		\
		'' using (bin(1)):(1) \
			smooth frequency with steps \
			notitle ls 1, \
			\
	'' using (bin(1)):(stringcolumn(2) eq "info" ? 1 : 0) \
		smooth frequency with fillsteps \
		title sprintf("Info %s", summary_interval_title) ls 2, \
		\
		'' using (bin(1)):(stringcolumn(2) eq "info" ? 1 : 0) \
			smooth frequency with steps \
			notitle ls 2, \
			\
	'' using (bin(1)):(stringcolumn(2) eq "warn" ? 1 : 0) \
		smooth frequency with fillsteps \
		title sprintf("Warning %s", summary_interval_title) ls 3, \
		\
		'' using (bin(1)):(stringcolumn(2) eq "warn" ? 1 : 0) \
			smooth frequency with steps \
			notitle ls 3, \
			\
	'' using (bin(1)):(stringcolumn(2) eq "error" ? 1 : 0) \
		smooth frequency with fillsteps \
		title sprintf("Error %s", summary_interval_title) ls 4, \
		\
		'' using (bin(1)):(stringcolumn(2) eq "error" ? 1 : 0) \
			smooth frequency with steps \
			notitle ls 4, \
	'' using @bin_x:( \
			day = @bin_x, prev_day == day \
				? (y = y + 1, 0) \
				: ( \
					prev_day = day, \
					bin = bin + 1, \
					sum = sum + y, \
					y > max ? (max = y, y = 1) : y = 1, \
					sum / (bin + 1) \
				) \
		) \
		smooth frequency with lines \
		title "Cumulative Average" ls 5, \
	keyentry title " ", \
	keyentry title sprintf("{/:Bold=20 %s}\n{/:=8 Generated by\n%s", script_title, parent_script)

# needs to track last_day to be able to plot the last day in the log
# maybe use replot <graph> to graph the average line, and just using the initial plot to store the data into an array?

set yrange [0:(floor(max / 10) * 10 + (max % 10 == 0 ? 0 : 10))]
set nonlinear y via sqrt(y) inverse y**2

replot
