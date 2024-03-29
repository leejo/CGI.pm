#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More tests => 71;

use CGI ();
use Config;

my $loaded = 1;

$| = 1;

$CGI::LIST_CONTEXT_WARN = 0;

######################### End of black magic.

# Set up a CGI environment
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{QUERY_STRING}    = 'game=chess&game=checkers&weather=dull';
$ENV{PATH_INFO}       = '/somewhere/else';
$ENV{PATH_TRANSLATED} = '/usr/local/somewhere/else';
$ENV{SCRIPT_NAME}     = '/cgi-bin/foo.cgi';
$ENV{SERVER_PROTOCOL} = 'HTTP/1.0';
$ENV{SERVER_PORT}     = 8080;
$ENV{SERVER_NAME}     = 'the.good.ship.lollypop.com';
$ENV{REQUEST_URI}     = "$ENV{SCRIPT_NAME}$ENV{PATH_INFO}?$ENV{QUERY_STRING}";
$ENV{HTTP_LOVE}       = 'true';

my $q = CGI->new;
ok $q,"CGI::new()";
is $q->request_method => 'GET',"CGI::request_method()";
is $q->query_string => 'game=chess;game=checkers;weather=dull',"CGI::query_string()";
is $q->param(), 2,"CGI::param()";
is join(' ',sort $q->param()), 'game weather',"CGI::param()";
is $q->param('game'), 'chess',"CGI::param()";
is $q->param('weather'), 'dull',"CGI::param()";
is join(' ',$q->param('game')), 'chess checkers',"CGI::param()";
ok $q->param(-name=>'foo',-value=>'bar'),'CGI::param() put';
is $q->param(-name=>'foo'), 'bar','CGI::param() get';
is $q->query_string, 'game=chess;game=checkers;weather=dull;foo=bar',"CGI::query_string() redux";
is $q->http('love'), 'true',"CGI::http()";
is $q->script_name, '/cgi-bin/foo.cgi',"CGI::script_name()";
is $q->url, 'http://the.good.ship.lollypop.com:8080/cgi-bin/foo.cgi',"CGI::url()";
is $q->self_url,
     'http://the.good.ship.lollypop.com:8080/cgi-bin/foo.cgi/somewhere/else?game=chess;game=checkers;weather=dull;foo=bar',
     "CGI::url()";
is $q->url(-absolute=>1), '/cgi-bin/foo.cgi','CGI::url(-absolute=>1)';
is $q->url(-relative=>1), 'foo.cgi','CGI::url(-relative=>1)';
is $q->url(-relative=>1,-path=>1), 'foo.cgi/somewhere/else','CGI::url(-relative=>1,-path=>1)';
is $q->url(-relative=>1,-path=>1,-query=>1), 
     'foo.cgi/somewhere/else?game=chess;game=checkers;weather=dull;foo=bar',
     'CGI::url(-relative=>1,-path=>1,-query=>1)';
$q->delete('foo');
ok !$q->param('foo'),'CGI::delete()';

$q->_reset_globals;
$ENV{QUERY_STRING}='mary+had+a+little+lamb';
ok $q=CGI->new,"CGI::new() redux";
is join(' ',$q->keywords), 'mary had a little lamb','CGI::keywords';
is join(' ',$q->param('keywords')), 'mary had a little lamb','CGI::keywords';
ok $q=CGI->new('foo=bar&foo=baz'),"CGI::new() redux";
is $q->param('foo'), 'bar','CGI::param() redux';
ok $q=CGI->new({'foo'=>'bar','bar'=>'froz'}),"CGI::new() redux 2";
is $q->param('bar'), 'froz',"CGI::param() redux 2";

# test tied interface
my $p = $q->Vars;
is $p->{bar}, 'froz',"tied interface fetch";
$p->{bar} = join("\0",qw(foo bar baz));
is join(' ',$q->param('bar')), 'foo bar baz','tied interface store';
ok exists $p->{bar};
is delete $p->{bar}, "foo\0bar\0baz",'tied interface delete';

# test posting
$q->_reset_globals;
{
  my $test_string = 'game=soccer&game=baseball&weather=nice';
  local $ENV{REQUEST_METHOD}='POST';
  local $ENV{CONTENT_LENGTH}=length($test_string);
  local $ENV{QUERY_STRING}='big_balls=basketball&small_balls=golf';

  local *STDIN;
  open STDIN, '<', \$test_string;

  ok $q=CGI->new,"CGI::new() from POST";
  is $q->param('weather'), 'nice',"CGI::param() from POST";
  is $q->url_param('big_balls'), 'basketball',"CGI::url_param()";
}

# test url_param 
{
    local $ENV{QUERY_STRING} = 'game=chess&game=checkers&weather=dull';

    CGI::_reset_globals;
    my $q = CGI->new;
    # params present, param and url_param should return true
    ok $q->param,     'param() is true if parameters';
    ok $q->url_param, 'url_param() is true if parameters';

    $ENV{QUERY_STRING} = '';

    CGI::_reset_globals;
    $q = CGI->new;
    ok !$q->param,     'param() is false if no parameters';
    ok !$q->url_param, 'url_param() is false if no parameters';

    $ENV{QUERY_STRING} = 'tiger dragon';
    CGI::_reset_globals;
    $q = CGI->new;

    is_deeply [$q->$_] => [ 'keywords' ], "$_ with QS='$ENV{QUERY_STRING}'" 
        for qw/ param url_param /;

    is_deeply [ sort $q->$_( 'keywords' ) ], [ qw/ dragon tiger / ],
        "$_ keywords" for qw/ param url_param /;

	{
		$^W++;

		CGI::_reset_globals;
		$q = CGI->new;
		$ENV{QUERY_STRING} = 'p1=1&&&;;&;&&;;p2;p3;p4=4&=p5';
		ok $q->url_param, 'url_param() is true if parameters';
		is_deeply( [ sort $q->url_param ], [ '', qw/p1 p2 p3 p4/ ], 'url_param' );
	}
}

# regression matrix for request types
foreach my $test (
	{ desc => "OPTIONS", param => [ undef,undef   ], url_param => 'basketball' },
	{ desc => "GET",     param => [ undef,'golf'  ], url_param => 'basketball' },
	{ desc => "HEAD",    param => [ undef,'golf'  ], url_param => 'basketball' },
	{ desc => "POST",    param => [ 'nice',undef  ], url_param => 'basketball' },
	{ desc => "PUT",     param => [ 'nice',undef  ], url_param => 'basketball' },
	{ desc => "TRACE",   param => [ undef,undef   ], url_param => 'basketball' },
	{ desc => "CONNECT", param => [ undef,undef   ], url_param => 'basketball' },
	{ desc => "DELETE",  param => [ undef,'golf'  ], url_param => 'basketball' },
	# first pass over DELETE will enable $CGI::ALLOW_DELETE_CONTENT
	{ desc => "DELETE",  param => [ 'nice','golf' ], url_param => 'basketball' },
) {
    CGI::_reset_globals;

	my $req_method = $test->{desc};
	my $test_string = 'game=soccer&game=baseball&weather=nice';
	local $ENV{REQUEST_METHOD} = $req_method;
	local $ENV{CONTENT_LENGTH} = length( $test_string );
	local $ENV{QUERY_STRING}   = 'big_balls=basketball&small_balls=golf';

	local *STDIN;
	open STDIN, '<', \$test_string;

    my $q = CGI->new;

	{
		is( $q->url_param('big_balls'),$test->{url_param},"CGI::url_param() from $req_method" );
		is( $q->param('small_balls'),$test->{param}[1],"CGI::param() from $req_method (query string)" );

		local $TODO = $CGI::ALLOW_DELETE_CONTENT ? "content with DELETE" : undef;
		is( $q->param('weather'),$test->{param}[0],"CGI::param() from $req_method (body)" );
	}

	if ( $req_method eq 'DELETE' ) {
		$CGI::ALLOW_DELETE_CONTENT++;
	}
}
