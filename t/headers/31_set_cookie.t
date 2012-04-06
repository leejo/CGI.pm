use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( '-Set-Cookie' => 'foo' );
    my $expected = "Set-cookie: foo$CGI::CRLF"
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'set-cookie';
}

{
    my $q = CGI->new;
    my $got = $q->header( '-Set-Cookie' => q{} );
    my $expected = "Set-cookie: \"$CGI::CRLF" # looks like a bug
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'set-cookie empty string';
}

done_testing;
