#!/usr/local/bin/perl -w

use Test::More tests => 177;

BEGIN{ use_ok('CGI', ':all'); }

my @tags = CGI::expand_tags(':all');

foreach my $tag ( @tags ) {
    eval " &$tag ";
    ok( $@ !~ /Undefined subroutine/, "$tag function defined" );
}
