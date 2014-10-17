#!perl

use strict;
use warnings;

use Test::More tests => 4;
use IO::File;
use CGI;

my $test_string = 'game=soccer&game=baseball&weather=nice';
my $handle = IO::File->new_tmpfile;
$handle->write( $test_string );
$handle->flush;
$handle->seek( 0,0 );

{
	local $ENV{REQUEST_METHOD} = 'POST';

	ok( my $q = CGI->new( $handle ),"CGI->new from POST" );
	is( $q->param( 'weather' ),'nice', "param() from POST with IO::File" );
}

$handle->seek( 0,0 );

{
	local $ENV{REQUEST_METHOD} = 'GET';

	ok( my $q = CGI->new( $handle ),"CGI->new from GET" );
	is( $q->param( 'weather' ),'nice', "param() from GET with IO::File" );
}
