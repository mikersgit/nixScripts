 #!/bin/bash

 # Command to output a count of unique process names in the lsof
 # output. It is assumed that the value to be grouped is in the first
 # column. The output is numeric sorted from high to low occurance
 # in the form of
 # proc number
 ##########

#sortkey='-k1,1'   #alpha sort by process name
sortkey='-rnk2,2' #numeric sort high to low

# if the 'lsof' line is commented out then this will count any
# input piped to it.
 lsof |
 awk 'BEGIN {f=1}
 {
 #skip the first line of input, it is the column header
 if (f) {f=0;next}
 val=$1
 pc[val]=pc[val]+1
 }
 END {for (a in pc)
        printf("%s %d\n",a,pc[a])
}' | sort ${sortkey}
