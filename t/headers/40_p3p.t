use strict;
use CGI;
use Test::More;

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -p3p => "CAO DSP LAW CURa" );
    my $expected = 'P3P: policyref="/w3c/p3p.xml", CP="CAO DSP LAW CURa"'
                 . $CGI::CRLF
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'p3p';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -p3p => [ qw/CAO DSP LAW CURa/ ] );
    my $expected = 'P3P: policyref="/w3c/p3p.xml", CP="CAO DSP LAW CURa"'
                 . $CGI::CRLF
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'p3p arrayref';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -p3p => q{} );
    my $expected = 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'p3p empty string';
}

done_testing;
