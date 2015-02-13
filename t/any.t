#!perl

use strict;
use warnings;

use Test::More;

BEGIN{ use_ok('CGI', '-any'); }

my $q = CGI->new;
eval { $q->some_none_existent_tag };
like( $@,qr/Can't locate object method/,'-any has been REMOVED' );

done_testing();
