use strict;
use CGI;
use Test::More;

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -attachment => 'foo.png' );
    my $expected = 'Content-Disposition: attachment; filename="foo.png"'
                 . $CGI::CRLF
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'attachment';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -attachment => q{} );
    my $expected = "Content-Type: text/html; charset=ISO-8859-1"
                 . $CGI::CRLF x 2;
    is $got, $expected, 'attachment empty string';
}

done_testing;
