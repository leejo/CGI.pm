#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More;

use CGI ();
use Config;

my $loaded = 1;

$| = 1;

$CGI::LIST_CONTEXT_WARN = 0;

######################### End of black magic.

# Set up a CGI environment
$ENV{REQUEST_METHOD}  = 'DELETE';
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
is $q->request_method => 'DELETE',"CGI::request_method()";
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

# test parameters in request body
$q->_reset_globals;
{
  my $test_string = 'game=soccer&game=baseball&weather=nice';
  local $ENV{REQUEST_METHOD}='DELETE';
  local $ENV{CONTENT_LENGTH}=length($test_string);
  local $ENV{QUERY_STRING}='big_balls=basketball&small_balls=golf';

  local *STDIN;
  open STDIN, '<', \$test_string;

  ok $q=CGI->new,"CGI::new() from DELETE";
  is $q->param('weather'), 'nice',"CGI::param() from DELETE";
  is $q->url_param('big_balls'), 'basketball',"CGI::url_param()";
}

done_testing();
