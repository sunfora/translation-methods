use strict;
use warnings;

while (<>) {
  print if /\b(\w+)\g{-1}\b/
}
