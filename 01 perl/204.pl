use strict;
use warnings;

while (<>) {
  print s/\b(\w+)\b(\W+)\b(\w+)\b/$3$2$1/r
}
