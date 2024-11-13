use strict;
use warnings;
my $name = "Ivan";
print
"  There is more than a one way to do this! 
  > Welcome $name!
";

while (<>) {
 next unless /^\s*\d+\s*$/;
 print;
}

