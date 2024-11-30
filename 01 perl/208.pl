use strict;
use warnings;

while (<>) {
  print s/(?|\b(\d+)0\b|\b(\d+)\b)/$1/rg 
}
