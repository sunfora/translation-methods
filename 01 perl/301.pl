use strict;
use warnings;

my $empty=0;
my $active=0;
while (<>) {
  if (/^\s*$/) {
    if ($active) {
      $empty = 1;
    }
    next;
  }
  $active=1;
  
  if ($empty) {
    print "\n";
    $empty = 0;
  }
  print s/\s+/ /rg =~
        s/^\s*(.*?)\s*$/$1\n/r
}
