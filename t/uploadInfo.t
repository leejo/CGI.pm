#!/usr/local/bin/perl -w

#################################################################
#  Emanuele Zeppieri, Mark Stosberg                             #
#  Shamelessly stolen from Data::FormValidator and CGI::Upload  #
#################################################################

use strict;
use Test::More 'no_plan';

use CGI qw/ :form /;

#-----------------------------------------------------------------------------
# %ENV setup.
#-----------------------------------------------------------------------------

my %myenv;

BEGIN {
    %myenv = (
        'SCRIPT_NAME'       => '/test.cgi',
        'SERVER_NAME'       => 'perl.org',
        'HTTP_CONNECTION'   => 'TE, close',
        'REQUEST_METHOD'    => 'POST',
        'SCRIPT_URI'        => 'http://www.perl.org/test.cgi',
        'CONTENT_LENGTH'    => 3285,
        'SCRIPT_FILENAME'   => '/home/usr/test.cgi',
        'SERVER_SOFTWARE'   => 'Apache/1.3.27 (Unix) ',
        'HTTP_TE'           => 'deflate,gzip;q=0.3',
        'QUERY_STRING'      => '',
        'REMOTE_PORT'       => '1855',
        'HTTP_USER_AGENT'   => 'Mozilla/5.0 (compatible; Konqueror/2.1.1; X11)',
        'SERVER_PORT'       => '80',
        'REMOTE_ADDR'       => '127.0.0.1',
        'CONTENT_TYPE'      => 'multipart/form-data; boundary=xYzZY',
        'SERVER_PROTOCOL'   => 'HTTP/1.1',
        'PATH'              => '/usr/local/bin:/usr/bin:/bin',
        'REQUEST_URI'       => '/test.cgi',
        'GATEWAY_INTERFACE' => 'CGI/1.1',
        'SCRIPT_URL'        => '/test.cgi',
        'SERVER_ADDR'       => '127.0.0.1',
        'DOCUMENT_ROOT'     => '/home/develop',
        'HTTP_HOST'         => 'www.perl.org'
    );

    for my $key (keys %myenv) {
        $ENV{$key} = $myenv{$key};
    }
}

END {
    for my $key (keys %myenv) {
        delete $ENV{$key};
    }
}


#-----------------------------------------------------------------------------
# Simulate the upload (really, multiple uploads contained in a single stream).
#-----------------------------------------------------------------------------

my $q;

{
    local *STDIN;
    open STDIN, '<t/upload_post_text.txt'
        or die 'missing test file t/upload_post_text.txt';
    binmode STDIN;
    $q = CGI->new;
}

{
    my $test = "uploadInfo: basic test";
    my $fh = $q->upload('300x300_gif');
    is( uploadInfo($fh)->{'Content-Type'}, "image/gif", $test);
    is( $q->uploadInfo($fh)->{'Content-Type'}, "image/gif", $test);

	# access using param
	my $param_value = $q->param( '300x300_gif' );
	ok( ref( $param_value ),'param returns filehandle' );
    is( $q->uploadInfo( $param_value )->{'Content-Type'}, "image/gif", $test . ' via param');

	# access using Vars (is not possible)
	my $vars = $q->Vars;
	ok( ! ref( $vars->{'300x300_gif'} ),'Vars does not return filehandle' );
    ok( ! $q->uploadInfo( $vars->{'300x300_gif'} ), $test . ' via Vars');
}

my $q2 = CGI->new;

{
    my $test = "uploadInfo: works with second object instance";
    my $fh = $q2->upload('300x300_gif');
    is( $q2->uploadInfo($fh)->{'Content-Type'}, "image/gif", $test);
}

