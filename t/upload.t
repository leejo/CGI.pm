#!/usr/local/bin/perl -w

#################################################################
#  Emanuele Zeppieri                                            #
#  Shamelessly stolen from Data::FormValidator and CGI::Upload  #
#################################################################

# Due to a bug in older versions of MakeMaker & Test::Harness, we must
# ensure the blib's are in @INC, else we might use the core CGI.pm
use lib qw(. ./blib/lib ./blib/arch);

use strict;

use Test::More tests => 8;

use CGI;

#-----------------------------------------------------------------------------
# %ENV setup.
#-----------------------------------------------------------------------------

%ENV = (
    %ENV,
    'SCRIPT_NAME'       => '/test.cgi',
    'SERVER_NAME'       => 'perl.org',
    'HTTP_CONNECTION'   => 'TE, close',
    'REQUEST_METHOD'    => 'POST',
    'SCRIPT_URI'        => 'http://www.perl.org/test.cgi',
    'CONTENT_LENGTH'    => 3129,
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

#-----------------------------------------------------------------------------
# Check that the file names retrieved by CGI are correct.
#-----------------------------------------------------------------------------

is( $q->param('hello_world')       , 'hello_world.txt'   , 'filename_1' );
is( $q->param('does_not_exist_gif'), 'does_not_exist.gif', 'filename_2' );
is( $q->param('100x100_gif')       , '100x100.gif'       , 'filename_3' );
is( $q->param('300x300_gif')       , '300x300.gif'       , 'filename_4' );

#-----------------------------------------------------------------------------
# Now check that the upload method works.
#-----------------------------------------------------------------------------

ok( defined $q->upload('hello_world')       , 'upload_basic_1' );
ok( defined $q->upload('does_not_exist_gif'), 'upload_basic_2' );
ok( defined $q->upload('100x100_gif')       , 'upload_basic_3' );
ok( defined $q->upload('300x300_gif')       , 'upload_basic_4' );

