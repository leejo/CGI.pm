use Test::More 'no_plan';

BEGIN {
	# assign
	$MultipartBuffer::INITIAL_FILLUNIT = 'A';
	$MultipartBuffer::TIMEOUT          = 'B';
	$MultipartBuffer::SPIN_LOOP_MAX    = 'C';
	$MultipartBuffer::CRLF             = 'D';
};

use CGI;

is( $MultipartBuffer::INITIAL_FILLUNIT,'A','INITIAL_FILLUNIT (assigned)' );
is( $MultipartBuffer::TIMEOUT,'B','TIMEOUT (assigned)' );
is( $MultipartBuffer::SPIN_LOOP_MAX,'C','SPIN_LOOP_MAX (assigned)' );
is( $MultipartBuffer::CRLF,'D','CRLF (assigned)' );

is( $CGI::MultipartBuffer::INITIAL_FILLUNIT,'A','INITIAL_FILLUNIT (assigned)' );
is( $CGI::MultipartBuffer::TIMEOUT,'B','TIMEOUT (assigned)' );
is( $CGI::MultipartBuffer::SPIN_LOOP_MAX,'C','SPIN_LOOP_MAX (assigned)' );
is( $CGI::MultipartBuffer::CRLF,'D','CRLF (assigned)' );
