#!perl

use strict;
use warnings;

use Test::More tests => 2;

use CGI qw/ autoEscape escapeHTML /;

my $before = escapeHTML("test<");
autoEscape(undef);
my $after = escapeHTML("test<");

is ($before, $after, "passing undef to autoEscape doesn't break escapeHTML"); 

$before = escapeHTML("test<");
autoEscape(0);
$after = escapeHTML("test<");

is ($before, $after, "passing 0 to autoEscape doesn't break escapeHTML"); 
