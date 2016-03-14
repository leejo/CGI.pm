#!perl

use strict;
use warnings;

use Test::More 'no_plan';
use CGI qw/ :cgi /;
$CGI::LIST_CONTEXT_WARN = 0;

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

my $q;

{
    local *STDIN;
	# note this file contains two uploads that both have the same
	# name and filename param values but have different content
    open STDIN, '<t/upload_post_text_duplicate_files.txt'
        or die 'missing test file t/upload_post_text.txt';
    binmode STDIN;
    $q = CGI->new;
}

#-----------------------------------------------------------------------------
# Check that the file names retrieved by CGI are correct.
#-----------------------------------------------------------------------------

{ 
    my $test = "multiple file names are handled right with same-named upload fields";
    my @hello_names = $q->param('hello_world');
    is ($hello_names[0],'hello_world.txt',$test. "...first file");
    is ($hello_names[1],'hello_world.txt',$test. "...second file");
	is ($hello_names[0],$hello_names[1],'filename values the same');
}

{
    my $test = "file handles have expected length for multi-valued field. ";
    my ($goodbye_fh,$hello_fh) = $q->upload('hello_world');

		is( <$goodbye_fh>,"Goodbye World!\n",'content of first file' );
		is( <$hello_fh>,"Hello World!\n",'content of second file' );

        # Go to end of file;
        seek($goodbye_fh,0,2);
        # How long is the file?
        is(tell($goodbye_fh), 15, "$test..first file");

        # Go to end of file;
        seek($hello_fh,0,2);
        # How long is the file?
        is(tell($hello_fh), 13, "$test..second file");

}
