#!/usr/local/bin/perl

# Useful little script to dump a message to a file for debugging.

use DBI;
use DBD::Oracle;
use strict;


if (scalar(@ARGV) != 2) {
  die "Usage: $0 dbuser/dbpw msg_id\n";
}

my $msg_id = $ARGV[1];

my $dbh = DBI->connect("dbi:Oracle:", $ARGV[0], '') || die $DBI::errstr;

$dbh->{RaiseError} = 1;
$dbh->{LongReadLen} = 10000000;



my $sth = $dbh->prepare("select name || ': ' || value 
from wm_headers
where msg_id = $msg_id");

$sth->execute;

while (my @row = $sth->fetchrow()) {
  print "$row[0]\n";
}
print "\n";

$sth->finish;

$sth = $dbh->prepare("select body
from wm_messages
where msg_id = $msg_id");

$sth->execute;

while (my @row = $sth->fetchrow_array()) {
    print "$row[0]\n";
}

$sth->finish;
$dbh->disconnect;


