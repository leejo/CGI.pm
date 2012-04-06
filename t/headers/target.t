use strict;
use CGI;
use Test::More;

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -target => 'ResultsWindow' );
    my $expected = "Window-Target: ResultsWindow$CGI::CRLF"
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'target';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -target => q{} );
    my $expected = 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'target empty string';
}

done_testing;
