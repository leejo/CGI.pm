#!/usr/local/bin/perl -w

#################################################################
#  Emanuele Zeppieri, Mark Stosberg                             #
#  Shamelessly stolen from Data::FormValidator and CGI::Upload  #
#  Anonymous Monk says me too                                   #
#################################################################

use strict;
use Test::More tests => 28;

use CGI;
$CGI::DEBUG=1;

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
        'CONTENT_LENGTH'    => 35,
        'SCRIPT_FILENAME'   => '/home/usr/test.cgi',
        'SERVER_SOFTWARE'   => 'Apache/1.3.27 (Unix) ',
        'HTTP_TE'           => 'deflate,gzip;q=0.3',
        'QUERY_STRING'      => '',
        'REMOTE_PORT'       => '1855',
        'HTTP_USER_AGENT'   => 'Mozilla/5.0 (compatible; Konqueror/2.1.1; X11)',
        'SERVER_PORT'       => '80',
        'REMOTE_ADDR'       => '127.0.0.1',
        'CONTENT_TYPE'      => 'application/octet-stream', ##dd
        'X_File_Name'       => 'tiny.gif', ##dd
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



for my $pdata ( qw' POST PUT ' ){
    local $ENV{REQUEST_METHOD} = $pdata;
    my $pdata = $pdata.'DATA';
    CGI::initialize_globals();  #### IMPORTANT
    ok( ! $CGI::PUTDATA_UPLOAD , "-\L$pdata\E_upload default is off");
    local *STDIN;
    open STDIN, "<", \"GIF89a\1\0\1\0\x90\0\0\xFF\0\0\0\0\0,\0\0\0\0\1\0\1\0\0\2\2\4\1\0;"
        or die "In-memory filehandle failed\n";
    binmode STDIN;
    my $q = CGI->new;
    ok( scalar $q->param( $pdata  ), "we have $pdata param" );
    ok( ! ref $q->param( $pdata  ), 'and it is not filehandle');
    ok( "GIF89a\1\0\1\0\x90\0\0\xFF\0\0\0\0\0,\0\0\0\0\1\0\1\0\0\2\2\4\1\0;" eq  $q->param( $pdata  ), "and the value isn't corrupted" );
}

for my $pdata ( qw' POST PUT ' ){
    local $ENV{REQUEST_METHOD} = $pdata;
    my $pdata = $pdata.'DATA';
    local *STDIN;
    open STDIN, "<", \"GIF89a\1\0\1\0\x90\0\0\xFF\0\0\0\0\0,\0\0\0\0\1\0\1\0\0\2\2\4\1\0;"
        or die "In-memory filehandle failed\n";
    binmode STDIN;
    
    CGI::initialize_globals();  #### IMPORTANT
    local $CGI::PUTDATA_UPLOAD;
    CGI->import( lc "-$pdata\_upload" );
    ok( !!$CGI::PUTDATA_UPLOAD, "-\L$pdata\E_upload default is on");
    
    my $q = CGI->new;
	foreach my $class ( 'File::Temp','CGI::File::Temp','Fh' ) {
    	isa_ok( $q->param( $pdata  ),$class,"$pdata param" );
	}
    
    my $filename = $q->param($pdata);
    my $tmpfilename = $q->tmpFileName( $filename );
    ok( $tmpfilename , "and tmpFileName returns the filename" );
}


for my $pdata ( qw' POST PUT ' ){
    local $ENV{REQUEST_METHOD} = $pdata;
    my $pdata = $pdata.'DATA';
    local *STDIN;
    open STDIN, "<", \"GIF89a\1\0\1\0\x90\0\0\xFF\0\0\0\0\0,\0\0\0\0\1\0\1\0\0\2\2\4\1\0;"
        or die "In-memory filehandle failed\n";
    binmode STDIN;
    
    CGI::initialize_globals();  #### IMPORTANT
    
    my $yourang  = 0;
    my $callback = sub {
        $yourang++;
    };
    my $q = CGI->new( $callback ); 
    ok( ref $q, "got query");
	foreach my $class ( 'File::Temp','CGI::File::Temp','Fh' ) {
    	isa_ok( $q->param( $pdata ),$class,"$pdata param" );
	}
    ok( $yourang, "and callback invoked");
}
