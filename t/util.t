#!/usr/local/bin/perl -w

# Test ability to escape() and unescape() punctuation characters
# except for qw(- . _).

$| = 1;

use Test::More tests => 80;
use Test::Deep;
use Config;
use_ok ( 'CGI::Util', qw(
	escape
	unescape
	rearrange
	ebcdic2ascii
	ascii2ebcdic
) );

# ASCII order, ASCII codepoints, ASCII repertoire

my %punct = (
    ' ' => '20',  '!' => '21',  '"' => '22',  '#' =>  '23', 
    '$' => '24',  '%' => '25',  '&' => '26',  '\'' => '27', 
    '(' => '28',  ')' => '29',  '*' => '2A',  '+' =>  '2B', 
    ',' => '2C',                              '/' =>  '2F',  # '-' => '2D',  '.' => '2E' 
    ':' => '3A',  ';' => '3B',  '<' => '3C',  '=' =>  '3D', 
    '>' => '3E',  '?' => '3F',  '[' => '5B',  '\\' => '5C', 
    ']' => '5D',  '^' => '5E',                '`' =>  '60',  # '_' => '5F',
    '{' => '7B',  '|' => '7C',  '}' => '7D',  # '~' =>  '7E', 
         );

# The sort order may not be ASCII on EBCDIC machines:

my $i = 1;

foreach(sort(keys(%punct))) { 
    $i++;
    my $escape = "AbC\%$punct{$_}dEF";
    my $cgi_escape = escape("AbC$_" . "dEF");
    is($escape, $cgi_escape , "# $escape ne $cgi_escape");
    $i++;
    my $unescape = "AbC$_" . "dEF";
    my $cgi_unescape = unescape("AbC\%$punct{$_}dEF");
    is($unescape, $cgi_unescape , "# $unescape ne $cgi_unescape");
}

# rearrange should return things in a consistent order, so when we pass through
# a hash reference it should sort the keys
for ( 1 .. 20 ) {
	my %args = (
		'-charset'      => 'UTF-8',
		'-type'         => 'text/html',
		'-content-type' => 'text/html; charset=iso-8859-1',
	);

	my @ordered = rearrange(
		[
			[ 'TYPE','CONTENT_TYPE','CONTENT-TYPE' ],
			'STATUS',
			[ 'COOKIE','COOKIES','SET-COOKIE' ],
			'TARGET',
			'EXPIRES',
			'NPH',
			'CHARSET',
			'ATTACHMENT',
			'P3P'
		],
		%args,
	);

	cmp_deeply(
		[ @ordered ],
		[
			'text/html; charset=iso-8859-1',
			undef,
			undef,
			undef,
			undef,
			undef,
			'UTF-8',
			undef,
			undef
		],
		'rearrange not sensitive to hash key ordering'
	);
}

ok( CGI::Util::utf8_chr( "1",1 ),'utf8_chr' );
ok( my $ebcdic = ascii2ebcdic( "A" ),'ascii2ebcdic' );
is( ebcdic2ascii( $ebcdic ),'A','ebcdic2ascii' );
