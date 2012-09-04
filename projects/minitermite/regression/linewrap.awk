#!/usr/bin/awk -f
# performing rudimentary Fortran 77 line-wrapping
# until USE_RICE_FORTRAN_WRAPPING is permanently enabled.
BEGIN {FS=","}
{ 
   if ($0 ~ /^      /) {
       line = $1
       len = length(line)
       for (i=2; i<=NF; i++) {
	   if (length($i)+len+1 < 72) {
	       line = line "," $i
	       len += length($i)+1
	   } else {
	       print line
	       line = "     &," $i
	       len = length(line)
	   }
       }
       print line
   } else print $0
}
