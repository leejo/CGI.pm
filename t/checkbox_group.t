#!/usr/local/bin/perl -w

use Test::More tests => 2;

BEGIN { use_ok('CGI'); };
use CGI (':standard','-no_debug','-no_xhtml');

is(checkbox_group(-name       => 'game',
		  '-values'   => [qw/checkers chess cribbage/],
                  '-defaults' => ['cribbage']),
   qq(<input type="checkbox" name="game" value="checkers" >checkers <input type="checkbox" name="game" value="chess" >chess <input type="checkbox" name="game" value="cribbage" checked >cribbage),
   'checkbox_group()');
