use strict;
use warnings;

while (<>) {
  print s/(\w)\g-1/$1/rg
}
