#!/usr/bin/env perl

use Mojolicious::Lite;
use Mojolicious::Plugin::CGI;

plugin CGI => [ '/clickable_image' => "clickable_image.cgi" ];
plugin CGI => [ '/cookie'          => "cookie.cgi" ];

app->start;