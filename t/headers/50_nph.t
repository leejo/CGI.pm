use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( -nph => 1 );
    my $expected = qr!^HTTP/1.0 200 OK${CGI::CRLF}Server: cmdline!;
    like $got, $expected, 'nph';
}

done_testing;
