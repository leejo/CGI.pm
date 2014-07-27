#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More tests => 44;
use Test::Deep;

use CGI ();
use Config;

my $loaded = 1;

$| = 1;

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

my $q = new CGI;
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
ok $q=new CGI,"CGI::new() redux";
is join(' ',$q->keywords), 'mary had a little lamb','CGI::keywords';
is join(' ',$q->param('keywords')), 'mary had a little lamb','CGI::keywords';
ok $q=new CGI('foo=bar&foo=baz'),"CGI::new() redux";
is $q->param('foo'), 'bar','CGI::param() redux';
ok $q=new CGI({'foo'=>'bar','bar'=>'froz'}),"CGI::new() redux 2";
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

  ok $q=new CGI,"CGI::new() from POST";
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
		# RT #54511. TODO: use Test::Warn / Test::Warnings / Test::NoWarnings
		$^W++;
		local $SIG{__WARN__} = sub { fail( "Got a warning: " . $_[0] ); };

		CGI::_reset_globals;
		$q = CGI->new;
		$ENV{QUERY_STRING} = 'p1=1&&&;;&;&&;;p2;p3;p4=4&=p5';
		ok $q->url_param, 'url_param() is true if parameters';
		cmp_deeply( [ $q->url_param ],bag( qw/p1 p2 p3 p4/,'' ),'url_param' );
	}
}
