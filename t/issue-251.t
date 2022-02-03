#!/usr/local/bin/perl

# test for https://github.com/leejo/CGI.pm/issues/251

use strict;
use warnings;
no warnings 'redefine';

use Test::More tests => 2;

use CGI::Cookie ();
use CGI ();

local $ENV{HTTP_COOKIE} = 'cookie1=value1; cookie2=value2; cookie3=value3';

my $fetch_counter = 0;
my $fetch_orig_sub = \&CGI::Cookie::fetch;
local *CGI::Cookie::fetch = sub {
    $fetch_counter++;
    goto &$fetch_orig_sub;
};

subtest 'cookie cache disabled' => sub {
    plan tests => 4;
    $fetch_counter = 0;
    $CGI::COOKIE_CACHE = 0;

    my $q = CGI->new;
    is($q->cookie('cookie1'), 'value1', 'cookie1 is correct');
    is($q->cookie('cookie2'), 'value2', 'cookie2 is correct');
    is($q->cookie('cookie3'), 'value3', 'cookie3 is correct');
    is($fetch_counter, 3, 'cookies were fetched on each `cookie` call');
};

subtest 'cookie cache enabled' => sub {
    plan tests => 4;
    $fetch_counter = 0;
    $CGI::COOKIE_CACHE = 1;

    my $q = CGI->new;
    is($q->cookie('cookie1'), 'value1', 'cookie1 is correct');
    is($q->cookie('cookie2'), 'value2', 'cookie2 is correct');
    is($q->cookie('cookie3'), 'value3', 'cookie3 is correct');
    is($fetch_counter, 1, 'cookies were fetched only once');
};
