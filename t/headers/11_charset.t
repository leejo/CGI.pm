use strict;
use CGI;
use Test::More;

{
    my $q = CGI->new;
    my $got = $q->header( -charset => 'utf-8' );
    my $expected = 'Content-Type: text/html; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'charset';
}

{
    my $q = CGI->new;
    my $got = $q->header( -charset => q{} );
    my $expected = 'Content-Type: text/html' . $CGI::CRLF x 2;
    is $got, $expected, 'charset empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => 'text/plain; charset=EUC-JP',
        '-charset'      => 'utf-8',
    );
    my $expected = "Content-Type: text/plain; charset=EUC-JP"
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type and charset';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => 'text/plain; charset=EUC-JP',
        '-charset'      => q{},
    );
    my $expected = 'Content-Type: text/plain; charset=EUC-JP'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type & charset, charset is empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => q{},
        '-charset'      => 'utf-8',
    );
    my $expected = $CGI::CRLF x 2;
    is $got, $expected, 'content-type & charset, content-type is empty string';
}

{
    my $q = CGI->new;
    my $got = $q->header(
        '-Content-Type' => 'text/plain',
        '-charset'      => 'utf-8',
    );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'content-type & charset, charset defines charset';
}

done_testing;
