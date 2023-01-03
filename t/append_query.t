#!/usr/local/bin/perl

use strict;
use warnings;

use Test::More tests => 18;

use CGI ();
use Config;

my $loaded = 1;

$| = 1;

######################### End of black magic.

my $test_string = 'game=soccer&game=baseball&weather=nice';

# Set up a CGI environment
$ENV{REQUEST_METHOD}  = 'POST';
$ENV{QUERY_STRING}    = 'big_balls=basketball&small_balls=golf';
$ENV{PATH_INFO}       = '/somewhere/else';
$ENV{PATH_TRANSLATED} = '/usr/local/somewhere/else';
$ENV{SCRIPT_NAME}     = '/cgi-bin/foo.cgi';
$ENV{SERVER_PROTOCOL} = 'HTTP/1.0';
$ENV{SERVER_PORT}     = 8080;
$ENV{SERVER_NAME}     = 'the.good.ship.lollypop.com';
$ENV{REQUEST_URI}     = "$ENV{SCRIPT_NAME}$ENV{PATH_INFO}?$ENV{QUERY_STRING}";
$ENV{HTTP_LOVE}       = 'true';
$ENV{CONTENT_LENGTH}  = length($test_string);

# APPEND_QUERY_STRING unset
{
    local *STDIN;
    open STDIN, '<', \$test_string;

    my $q = CGI->new;
    ok $q,"CGI::new()";
    is $q->param('weather'), 'nice',"CGI::param() from POST";
    is $q->param('big_balls'), undef, "CGI::param() from QUERY_STRING";
    is $q->param('small_balls'), undef,"CGI::param() from QUERY_STRING";
    is $q->url_param('big_balls'), 'basketball',"CGI::url_param()";
    is $q->url_param('small_balls'), 'golf',"CGI::url_param()";
}

# APPEND_QUERY_STRING = 0
{
    CGI::_reset_globals;

    $CGI::APPEND_QUERY_STRING = 0;

    local *STDIN;
    open STDIN, '<', \$test_string;

    my $q = CGI->new;
    ok $q,"CGI::new()";
    is $q->param('weather'), 'nice',"CGI::param() from POST";
    is $q->param('big_balls'), undef, "CGI::param() from QUERY_STRING";
    is $q->param('small_balls'), undef,"CGI::param() from QUERY_STRING";
    is $q->url_param('big_balls'), 'basketball',"CGI::url_param()";
    is $q->url_param('small_balls'), 'golf',"CGI::url_param()";
}

# APPEND_QUERY_STRING = 1
{
    CGI::_reset_globals;

    $CGI::APPEND_QUERY_STRING = 1;

    local *STDIN;
    open STDIN, '<', \$test_string;

    my $q = CGI->new;
    ok $q,"CGI::new()";
    is $q->param('weather'), 'nice',"CGI::param() from POST";
    is $q->param('big_balls'), 'basketball',"CGI::param() from QUERY_STRING";
    is $q->param('small_balls'), 'golf',"CGI::param() from QUERY_STRING";
    is $q->url_param('big_balls'), 'basketball',"CGI::url_param()";
    is $q->url_param('small_balls'), 'golf',"CGI::url_param()";
}
