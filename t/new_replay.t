#!perl

# a second CGI->new in the same request replays the first object's request
# (as e.g. STDIN can't be read again): it must also see any error from
# parsing the request, and must not share the first object's param arrays

use strict;
use warnings;

use Test::More;
use CGI;

$CGI::LIST_CONTEXT_WARN = 0;

{
    # a malformed body, after one part was parsed
    my $body = "--XB\r\nContent-Disposition: form-data; name=\"a\"\r\n\r\n1\r\n--XB\r\nno header end";
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'POST';
    local $ENV{CONTENT_TYPE}   = 'multipart/form-data; boundary=XB';
    local $ENV{CONTENT_LENGTH} = length $body;
    local $ENV{QUERY_STRING}   = '';
    local *STDIN;
    open STDIN, '<', \$body or die "In-memory filehandle failed: $!\n";

    my $q1 = CGI->new;
    my $q2 = CGI->new;
    is( $q1->cgi_error, '400 Bad request (malformed multipart POST)', 'first object has the parse error' );
    is_deeply( [ $q2->param ], [ $q1->param ], ' ... second object has the same params' );
    is( $q2->cgi_error, $q1->cgi_error, ' ... and the same error' );

    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'GET';
    local $ENV{QUERY_STRING}   = 'b=2';
    my $q3 = CGI->new;
    is( $q3->cgi_error, undef, ' ... but it is not carried over once the globals are reset' );
}

{
    CGI::initialize_globals();
    local $ENV{REQUEST_METHOD} = 'GET';
    local $ENV{QUERY_STRING}   = 'role=user';

    my $q1 = CGI->new;
    $q1->append( -name => 'role', -values => [ 'admin' ] );
    push @{ $q1->param_fetch('role') }, 'root';

    my $q2 = CGI->new;
    is_deeply( [ $q2->multi_param('role') ], [ 'user' ], 'changes to the first object\'s params are not seen by later objects' );
    is_deeply( [ $q1->multi_param('role') ], [ qw/ user admin root / ], ' ... but are kept in the first object' );

    $q2->param( -name => 'role', -value => 'other' );
    my $q3 = CGI->new;
    is_deeply( [ $q3->multi_param('role') ], [ 'user' ], ' ... nor are changes to a replayed object\'s params' );
}

done_testing();
