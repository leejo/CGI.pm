#!perl

use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin $Script/;

plan tests => 1;

use CGI::Carp;

chdir( $Bin );

open( my $fh,"<","$Script" )
    || die "Can't open $Script for read: $!";

while ( <$fh> ) {
    eval { die("error") if /error/; };
    $@ && do {
        like( $@,qr!at \Q$0\E line 19!,'die with input line number' );
        last;
    }
}
close( $fh );
