#!/usr/local/bin/perl

# test for https://github.com/leejo/CGI.pm/issues/251

use strict;
use warnings;
no warnings 'redefine';

use Test::More tests => 4;

use CGI::Cookie ();
use CGI ();

local $ENV{HTTP_COOKIE} = 'cookie1=value1; cookie2=value2; cookie3=value3';

my $fetch_counter = 0;
my $fetch_orig_sub = \&CGI::Cookie::fetch;
local *CGI::Cookie::fetch = sub {
    $fetch_counter++;
    goto &$fetch_orig_sub;
};

my $q = CGI->new;

is($q->cookie('cookie1'), 'value1', 'cookie1 is correct');
is($q->cookie('cookie2'), 'value2', 'cookie2 is correct');
is($q->cookie('cookie3'), 'value3', 'cookie3 is correct');

is($fetch_counter, 1, 'cookies were fetched only once');

