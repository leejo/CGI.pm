use strict;
use warnings;

use Test::More;
use utf8;

use CGI ':all';
use CGI::Util qw/ unescape /;

delete( $ENV{SCRIPT_NAME} ); # Win32 fix, see RT 89992
$ENV{HTTP_X_FORWARDED_HOST} = 'proxy:8484';
$ENV{SERVER_PROTOCOL}       = 'HTTP/1.0';
$ENV{SERVER_PORT}           = 8080;
$ENV{SERVER_NAME}           = 'the.good.ship.lollypop.com';

is virtual_port() => 8484, 'virtual_port()';
is server_port()  => 8080, 'server_port()';

is url() => 'http://proxy:8484/', 'url()';

$ENV{HTTP_X_FORWARDED_HOST} = '192.169.1.1, proxy1:80, 127.0.0.1, proxy2:8484';

is url() => 'http://proxy2:8484/', 'url() with multiple proxies';

# let's see if we do the defaults right

$ENV{HTTP_X_FORWARDED_HOST} = 'proxy:80';

is url() => 'http://proxy/', 'url() with default port';

subtest 'rewrite_interactions' => sub {
    # Reference: RT#45019

    local $ENV{HTTP_X_FORWARDED_HOST} = undef;
    local $ENV{SERVER_PROTOCOL}       = undef;
    local $ENV{SERVER_PORT}           = undef;
    local $ENV{SERVER_NAME}           = undef;

    # These two are always set
    local $ENV{'SCRIPT_NAME'}     = '/real/cgi-bin/dispatch.cgi';
    local $ENV{'SCRIPT_FILENAME'} = '/home/mark/real/path/cgi-bin/dispatch.cgi';

    # These two are added by mod_rewrite Ref: http://httpd.apache.org/docs/2.2/mod/mod_rewrite.html

    local $ENV{'SCRIPT_URL'}      = '/real/path/info';
    local $ENV{'SCRIPT_URI'}      = 'http://example.com/real/path/info';

    local $ENV{'PATH_INFO'}       = '/path/info';
    local $ENV{'REQUEST_URI'}     = '/real/path/info';
    local $ENV{'HTTP_HOST'}       = 'example.com';

    my $q = CGI->new;

    is(
        $q->url( -absolute => 1, -query => 1, -path_info => 1 ),
        '/real/path/info',
        '$q->url( -absolute => 1, -query => 1, -path_info => 1 ) should return complete path, even when mod_rewrite is detected.'
    );
    is( $q->url(), 'http://example.com/real', '$q->url(), with rewriting detected' );
    is( $q->url(-full=>1), 'http://example.com/real', '$q->url(-full=>1), with rewriting detected' );
    is( $q->url(-path=>1), 'http://example.com/real/path/info', '$q->url(-path=>1), with rewriting detected' );
    is( $q->url(-path=>0), 'http://example.com/real', '$q->url(-path=>0), with rewriting detected' );
    is( $q->url(-full=>1,-path=>1), 'http://example.com/real/path/info', '$q->url(-full=>1,-path=>1), with rewriting detected' );
    is( $q->url(-rewrite=>1,-path=>0), 'http://example.com/real', '$q->url(-rewrite=>1,-path=>0), with rewriting detected' );
    is( $q->url(-rewrite=>1), 'http://example.com/real',
                                                '$q->url(-rewrite=>1), with rewriting detected' );
    is( $q->url(-rewrite=>0), 'http://example.com/real/cgi-bin/dispatch.cgi',
                                                '$q->url(-rewrite=>0), with rewriting detected' );
    is( $q->url(-rewrite=>0,-path=>1), 'http://example.com/real/cgi-bin/dispatch.cgi/path/info',
                                                '$q->url(-rewrite=>0,-path=>1), with rewriting detected' );
    is( $q->url(-rewrite=>1,-path=>1), 'http://example.com/real/path/info',
                                                '$q->url(-rewrite=>1,-path=>1), with rewriting detected' );
    is( $q->url(-rewrite=>0,-path=>0), 'http://example.com/real/cgi-bin/dispatch.cgi',
                                                '$q->url(-rewrite=>0,-path=>1), with rewriting detected' );
};

subtest 'RT#58377: + in PATH_INFO' => sub {
    local $ENV{PATH_INFO}             = '/hello+world';
    local $ENV{HTTP_X_FORWARDED_HOST} = undef;
    local $ENV{'HTTP_HOST'}           = 'example.com';
    local $ENV{'SCRIPT_NAME'}         = '/script/plus+name.cgi';
    local $ENV{'SCRIPT_FILENAME'}     = '/script/plus+filename.cgi';

    my $q = CGI->new;
    is($q->url(), 'http://example.com/script/plus+name.cgi', 'a plus sign in a script name is preserved when calling url()');
    is($q->path_info(), '/hello+world', 'a plus sign in a script name is preserved when calling path_info()');
};

subtest 'IIS PATH_INFO eq SCRIPT_NAME' => sub {
	$CGI::IIS++;
    local $ENV{PATH_INFO}           = '/hello+world';
    local $ENV{HTTP_X_FORWARDED_HOST} = undef;
    local $ENV{HTTP_HOST}           = 'example.com';
    local $ENV{SCRIPT_NAME}         = '/hello+world';

    my $q = CGI->new;
    is( $q->url,'http://example.com/hello+world','PATH_INFO being the same as SCRIPT_NAME');
};

subtest 'Escaped question marks preserved' => sub {
    local $ENV{HTTP_X_FORWARDED_HOST} = undef;
    local $ENV{HTTP_HOST}           = 'example.com';
    local $ENV{PATH_INFO}           = '/path/info';
    local $ENV{REQUEST_URI}         = '/real/path/info%3F';
    local $ENV{SCRIPT_NAME}         = '/real/cgi-bin/dispatch.cgi';
    local $ENV{SCRIPT_FILENAME}     = '/home/mark/real/path/cgi-bin/dispatch.cgi';

    my $q = CGI->new;
    is( $q->url(-absolute=>1), '/real/path/info?' );
};

subtest 'ipv6' => sub {

    delete( $ENV{$_} ) for qw/
        HTTP_X_FORWARDED_HOST
        SERVER_PROTOCOL
        SERVER_PORT
        SERVER_NAME
    /;

    local $ENV{HTTP_HOST} = '[::1]:5000';

    my $cgi = CGI->new;
    is( $cgi->http('HTTP_HOST'), '[::1]:5000', 'HTTP_HOST' );
    is( $cgi->url, 'http://[::1]:5000/', 'url'  );
};

if ( $] >= 5.018000 ) {
	# tests added to check URI encoded specific to hostnames
	# these break before 5.18 so ignore them. if anyone is hitting
	# this edge case on a (now) ten year old Perl they can fix
	# themselves and submit a PR as i'm not interested in fixing this
	subtest 'complex and utf8' => sub {

		local $ENV{HTTP_HOST}   = 'foo:bärbaz@boz.com:8000';
		local $ENV{REQUEST_URI} = '/biz/blap.cgi?boz=biz&buz=1#/!%?@3';

		my $expect = 'http://foo:b%E4rbaz@boz.com:8000/biz/blap.cgi';
		my $expect_ue = 'http://foo:bärbaz@boz.com:8000/biz/blap.cgi';
		my $cgi = CGI->new;

		is( $cgi->url,$expect,'->url' );
		is( $cgi->unescape($cgi->url),$expect_ue,'->url via unescape' );
		is( CGI::Util::unescape($cgi->url),$expect_ue,'->url via unescape' );
		is( unescape($cgi->url),$expect_ue,'->url via unescape' );
	};
}

subtest 'unescape' => sub {

    local $ENV{HTTP_HOST} = 'example.com';
    local $ENV{PATH_INFO} = '/path/info';

	my $expect = 'http://example.com/';
    my $cgi = CGI->new;

    is( $cgi->url,$expect,'->url' );
	is( $cgi->unescape($cgi->url),$expect,'->url via unescape' );
	is( CGI::Util::unescape($cgi->url),$expect,'->url via unescape' );
	is( unescape($cgi->url),$expect,'->url via unescape' );
};

done_testing();
