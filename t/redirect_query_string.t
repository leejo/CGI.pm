#!perl

use strict;
use warnings;

use Test::More 'no_plan';
use CGI;

# monkey patching to make testing easier
no warnings 'once';
no warnings 'redefine';
*CGI::read_multipart_related = sub {};
*CGI::save_request           = sub {};

my $q_string = 'foo=bar';

$ENV{REQUEST_METHOD} = 'POST';
$ENV{CONTENT_TYPE}   = 'multipart/related;boundary="------- =A; start=X';

{
    $ENV{QUERY_STRING}   = $q_string;
    my $q = CGI->new;
    is( $q->query_string,$q_string,'query_string' );
}

{
    $ENV{REDIRECT_QUERY_STRING}
        = delete( $ENV{QUERY_STRING} );

    my $q = CGI->new;
    is( $q->query_string,$q_string,'query_string (redirect)' );
}

{
    $ENV{REDIRECT_REDIRECT_QUERY_STRING}
        = delete( $ENV{REDIRECT_QUERY_STRING} );

    my $q = CGI->new;
    is( $q->query_string,$q_string,'query_string (redirect x 2)' );
}

{
    $ENV{REDIRECT_REDIRECT_REDIRECT_QUERY_STRING}
        = delete( $ENV{REDIRECT_REDIRECT_QUERY_STRING} );

    my $q = CGI->new;
    is( $q->query_string,$q_string,'query_string (redirect x 3)' );
}

{
    $ENV{REDIRECT_REDIRECT_REDIRECT_REDIRECT_QUERY_STRING}
        = delete( $ENV{REDIRECT_REDIRECT_REDIRECT_QUERY_STRING} );

    my $q = CGI->new;
    is( $q->query_string,$q_string,'query_string (redirect x 4)' );
}

{
    $ENV{REDIRECT_REDIRECT_REDIRECT_REDIRECT_REDIRECT_QUERY_STRING}
        = delete( $ENV{REDIRECT_REDIRECT_REDIRECT_REDIRECT_QUERY_STRING} );

    my $q = CGI->new;
    is( $q->query_string,$q_string,'query_string (redirect x 5)' );
}

{
    $ENV{REDIRECT_REDIRECT_REDIRECT_REDIRECT_REDIRECT_REDIRECT_QUERY_STRING}
        = delete( $ENV{REDIRECT_REDIRECT_REDIRECT_REDIRECT_REDIRECT_QUERY_STRING} );

    my $q = CGI->new;
    is( $q->query_string,'','no more than 5 redirects supported' );
}
