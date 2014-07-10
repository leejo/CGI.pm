
use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok 'CGI', qw/ -compile :form / };

is end_form() => '</form>', 'end_form()';
