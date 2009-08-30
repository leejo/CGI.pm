#!perl

use strict;
use warnings;

use Test::More tests => 1;

use CGI qw/ autoEscape escapeHTML /;

my $before = escapeHTML("test<");
autoEscape(0);
my $after = escapeHTML("test<");

is ($before, $after, "passing undef to autoEscape doesn't break escapeHTML"); 
