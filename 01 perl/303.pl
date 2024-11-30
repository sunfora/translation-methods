use strict;
use warnings;

my %result = ();
while (<>) {
  my @values = m!<a[^<>]*?href=(['"])([^<>'"]*?)\g1[^<>]*?>!g;
  foreach my $value (@values) {
    $value =~ m!
      ((?&scheme)://)?([^?/#]*?@)?
                   (?<hst>[^?/#:]*?)
                   (:(?&port))?
                   (?&athend)
                   
    (?(DEFINE)
      (?<athend>
        ([?#/]|$))
      (?<scheme> ([[:alpha:]]
                  [[:alnum:]+-\.]*))
      (?<userinfo> (.*?))
      (?<host> ([^:]*?))
      (?<port> (\d+)))
      !x;
    my $hst = $+{hst};
    $hst =~ s/^\[(.*)\]$/$1/;
    $result{"$hst"}=1;
  }
}
foreach (sort (keys %result)) {
  print;
  print "\n";
}
