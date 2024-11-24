use strict;
use warnings;

while (<>) {
  my $cl = "[xyz]";
  print if /${cl}.{5,17}${cl}/
}
