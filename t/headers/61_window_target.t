use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( '-Window-Target' => 'ResultsWindow' );
    my $expected = "Window-target: ResultsWindow$CGI::CRLF"
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'target';
}

done_testing;
