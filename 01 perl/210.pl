
use strict;
use warnings;

# okay consider [abbbabbba][aca][ada]
# that's why it doesn't work
# if we do . -> [^a]
# for real

while (<>) {
  print s/(a.*?a){3}/bad/rg 
}
