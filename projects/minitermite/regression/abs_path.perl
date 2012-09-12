#!/usr/bin/perl
# on Linux, we can use readlink -f to get the absolute filename, but on OS X, we need to use perl
use Cwd "abs_path";
print abs_path(shift);
