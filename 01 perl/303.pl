#!/usr/bin/perl
use strict;
use warnings;

local $/;
my $html = <>;
$html =~ s/\R//g;

my %result = ();
my @values; 
while ($html =~ /<\s*a[^<>]*?href\s*=\s*(['"])\s*(?<href>[^<>'"]*?)\s*\g1[^<>]*?>/g) {
  push @values, $+{href};
}

foreach my $url (@values) {
  my $host = "";
  if ($url =~ m{^[a-zA-Z]+://(?:[^@]*@)?(?<host>[^/:?#]+)}) {
    # URL with scheme
    $host = $+{host}
  }
  $host =~ s/^\[(.*)\]$/$1/; 
  $result{$host} = 1 if length($host);
}

foreach my $host (sort keys %result) {
    print "$host\n";
}
