#!perl

# this is a .pl to stop it running under prove

use strict;
use warnings;

use Test::More;

plan skip_all => "set DEV_TESTS=1 to run"
    if ! $ENV{DEV_TESTS};

# find perlbrew

# check available perls and all installed (except < 5.6.2)

# run tests

done_testing();
