#!/usr/bin/awk -f
# performing rudimentary line-wrapping until USE_RICE_FORTRAN_WRAPPING is permanently enabled.
{ if (($0 ~ /^      /) && length($0) > 72) {
    print substr($0, 0, 72);
    rem = substr($0, 67);
    while (length(rem) > 67) {
	print "    &" rem;
	rem = substr(rem, 67);
    }
    print "    &" rem;    
  } else print $0
}
