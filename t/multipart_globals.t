use Test::More 'no_plan';

BEGIN {
	# assign
	$MultipartBuffer::INITIAL_FILLUNIT = 'A';
	$MultipartBuffer::SPIN_LOOP_MAX    = 'C';
	$MultipartBuffer::CRLF             = 'D';
};

use CGI;

is( $MultipartBuffer::INITIAL_FILLUNIT,'A','INITIAL_FILLUNIT (assigned)' );
is( $MultipartBuffer::SPIN_LOOP_MAX,'C','SPIN_LOOP_MAX (assigned)' );
is( $MultipartBuffer::CRLF,'D','CRLF (assigned)' );
