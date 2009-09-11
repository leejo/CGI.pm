#!perl

use strict;
use warnings;

use Test::More tests => 6;

use CGI qw/ autoEscape escapeHTML button/;

is (button(-name => 'test<'), '<input type="button"  name="test&lt;" value="test&lt;" />', "autoEscape defaults to On");

my $before = escapeHTML("test<");
autoEscape(undef);
my $after = escapeHTML("test<");


is($before, "test&lt;", "reality check escapeHTML");

is ($before, $after, "passing undef to autoEscape doesn't break escapeHTML"); 
is (button(-name => 'test<'), '<input type="button"  name="test<" value="test<" />', "turning off autoescape actually works");
autoEscape(1);
is (button(-name => 'test<'), '<input type="button"  name="test&lt;" value="test&lt;" />', "autoescape turns back on");
$before = escapeHTML("test<");
autoEscape(0);
$after = escapeHTML("test<");

is ($before, $after, "passing 0 to autoEscape doesn't break escapeHTML"); 
