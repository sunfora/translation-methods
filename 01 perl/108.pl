use strict;
use warnings;

while (<>) {
  print if /
    \(
      [^()]*? # don't nest
        \b 
          \w+ # match a word
        \b
      [^()]* # don't nest
    \)
  /x
}
