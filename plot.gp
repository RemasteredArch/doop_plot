set term wxt title "Doop log" size 1200,1200 font "sans,12"
set title "Doop log"
input_data = "doop-log.txt.csv"

summary_interval = 60 * 60 * 24 # one day in seconds

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

# graphs
set linetype 1 linecolor "gray" linewidth 2 # total
set linetype 2 linecolor "blue" linewidth 2 # info
set linetype 3 linecolor "green" linewidth 2 # warn
set linetype 4 linecolor "red" linewidth 2 # error
set style fill transparent solid 0.5 border # fill with 25% opacity and a border

bin(x, width) = width * floor(x / width)

# plots the frequency of occurences over `summary_interval` seconds
# some boxes are wider because they expand to fill places where there are no entries
# good styles: boxes, impulses, histep, fillsteps
plot \
	input_data using (bin(timecolumn(1), summary_interval)):(1) \
		smooth frequency with fillsteps \
		title sprintf("Entries over %ds", summary_interval) ls 1, \
		\
		'' using (bin(timecolumn(1), summary_interval)):(1) \
			smooth frequency with steps \
			notitle ls 1, \
			\
	'' using (bin(timecolumn(1), summary_interval)):(stringcolumn(2) eq "info" ? 1 : 0) \
		smooth frequency with fillsteps \
		title "Info logs" ls 2, \
		\
		'' using (bin(timecolumn(1), summary_interval)):(stringcolumn(2) eq "info" ? 1 : 0) \
			smooth frequency with steps \
			notitle ls 2, \
			\
	'' using (bin(timecolumn(1), summary_interval)):(stringcolumn(2) eq "warn" ? 1 : 0) \
		smooth frequency with fillsteps \
		title "Warn logs" ls 3, \
		\
		'' using (bin(timecolumn(1), summary_interval)):(stringcolumn(2) eq "warn" ? 1 : 0) \
			smooth frequency with steps \
			notitle ls 3, \
			\
	'' using (bin(timecolumn(1), summary_interval)):(stringcolumn(2) eq "error" ? 1 : 0) \
		smooth frequency with fillsteps \
		title "Error logs" ls 4, \
		\
		'' using (bin(timecolumn(1), summary_interval)):(stringcolumn(2) eq "error" ? 1 : 0) \
			smooth frequency with steps \
			notitle ls 4
