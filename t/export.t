#!perl

use strict;
use warnings;

use Test::More tests => 177;

BEGIN{ use_ok('CGI', ':all'); }

my @tags = CGI::expand_tags(':all');

foreach my $tag ( @tags ) {
    local $^W = 0; # since we're calling functions without args
    eval " &$tag ";
    ok( $@ !~ /Undefined subroutine/, "$tag function defined" );
}
