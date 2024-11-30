use strict;
use warnings;

while (<>) {
  print s/\b(\w)(\w)(\w*)\b/$2$1$3/rg
}
