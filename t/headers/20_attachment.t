use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( -attachment => 'foo.png' );
    my $expected = 'Content-Disposition: attachment; filename="foo.png"'
                 . $CGI::CRLF
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'attachment';
}

{
    my $q = CGI->new;
    my $got = $q->header( -attachment => q{} );
    my $expected = "Content-Type: text/html; charset=ISO-8859-1"
                 . $CGI::CRLF x 2;
    is $got, $expected, 'attachment empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Disposition' => 'attachment; filename="foo.png"',
    );
    my $expected = 'Content-disposition: attachment; filename="foo.png"'
                 . $CGI::CRLF
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-disposition';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Disposition' => 'attachment; filename="foo.png"',
        '-attachment'          => 'bar.png',
    );
    my $expected = 'Content-Disposition: attachment; filename="bar.png"'
                 . $CGI::CRLF
                 . 'Content-disposition: attachment; filename="foo.png"'
                 . $CGI::CRLF
                 . 'Content-Type: text/html; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-disposition and attachment';
}

done_testing;
