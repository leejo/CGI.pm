#!perl

# import_names() imports params into a namespace, first clearing it when
# asked to (always under mod_perl / FastCGI) - which must not wipe nested
# packages in it

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

{
    package R::Config;
    sub secret { 's3cret' }
    our @list = ( 1, 2 );
}

my $q = CGI->new('a=1;b=x;b=y;9lives=cat;has-dash=d');

{
    no warnings 'once';
    $R::stale = 'stale';
    @R::stale = ( 'stale' );
}

$q->import_names( 'R', 1 );

{
    no warnings 'once';
    is( $R::a, 1, 'params are imported as scalars' );
    is_deeply( \@R::b, [ qw/ x y / ], ' ... and arrays' );
    is( $R::_9lives, 'cat', ' ... with names made safe' );
    is( $R::has_dash, 'd', ' ... including dashes' );
    ok( ! defined $R::stale, 'with delete, existing scalars are cleared' );
    ok( ! @R::stale, ' ... and arrays' );
}

ok( R::Config->can('secret'), 'a nested package\'s subs survive' );
is( eval { R::Config::secret() }, 's3cret', ' ... and still work' );
is_deeply( [ @{ $R::Config::{list} ? *{ $R::Config::{list} }{ARRAY} : [] } ], [ 1, 2 ], ' ... as do its variables' );

{
    # as under mod_perl / FastCGI, where the namespace is always cleared
    local $ENV{FCGI_ROLE} = 'RESPONDER';
    $q->import_names('R');
    ok( R::Config->can('secret'), 'a nested package survives the FastCGI clear too' );
}

eval { $q->import_names('main') };
like( $@, qr/Can't import names into "main"/, 'importing into main is still refused' );

done_testing();
