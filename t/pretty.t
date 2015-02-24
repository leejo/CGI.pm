#!/bin/perl -w

use strict;
use Test::More tests => 6;
use CGI::Pretty ':all';

is(h1(), '<h1 />',"single tag (pretty turned off)");
is(h1('fred'), '<h1>fred</h1>',"open/close tag (pretty turned off)");
is(h1('fred','agnes','maura'), '<h1>fred agnes maura</h1>',"open/close tag multiple (pretty turned off)");
is(h1({-align=>'CENTER'},'fred'), '<h1 align="CENTER">fred</h1>',"open/close tag with attribute (pretty turned off)");
is(h1({-align=>undef},'fred'), '<h1 align>fred</h1>',"open/close tag with orphan attribute (pretty turned off)");
is(h1({-align=>'CENTER'},['fred','agnes']), '<h1 align="CENTER">fred</h1> <h1 align="CENTER">agnes</h1>',
   "distributive tag with attribute (pretty turned off)");
