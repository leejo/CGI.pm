use strict;
use CGI;
use Test::More;

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -type => 'text/plain' );
    my $expected = 'Content-Type: text/plain; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -type => q{} );
    my $expected = $CGI::CRLF x 2;
    is $got, $expected, 'type empty string';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -type => 'text/plain; charset=utf-8' );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type defines charset';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header(
        '-type'    => 'text/plain',
        '-charset' => 'utf-8',
    );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header(
        '-type'    => q{},
        '-charset' => 'utf-8',
    );
    my $expected = $CGI::CRLF x 2;
    is $got, $expected, 'type and charset, type is empty string';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header(
        '-type'    => 'text/plain; charset=utf-8',
        '-charset' => q{},
    );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset, charset is empty string';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header(
        '-type'    => 'text/plain; charset=utf-8',
        '-charset' => 'EUC-JP',
    );
    my $expected = 'Content-Type: text/plain; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'type and charset, type defines charset';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header( -type => 'image/gif' );
    my $expected = 'Content-Type: image/gif; charset=ISO-8859-1'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'image type, no charset';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header(
		-type    => 'image/gif',
		-charset => '',
	);
    my $expected = 'Content-Type: image/gif'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'image type, no charset';
}

{
    my $cgi = CGI->new;
    my $got = $cgi->header(
        -type    => 'image/gif',
        -charset => 'utf-8',
    );
    my $expected = 'Content-Type: image/gif; charset=utf-8'
                 . $CGI::CRLF x 2;
    is $got, $expected, 'image type, forced charset';
}

done_testing;
