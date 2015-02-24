
use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok 'CGI', qw/ :form / };

is end_form() => '</form>', 'end_form()';
