#!perl

use strict;
use warnings;

use Test::More 'no_plan';
use CGI;

# Mix hash and old parammeters
my $p = {
    'class'    => 'class_set',
    '-default' => [''],
    '-name'    => 'name_set',
    'id'       => 'id_set'
};

sub _test {
    my $cnt = 100;
    my $err = 0;
    for (1 .. $cnt) {
        my $cg    = CGI->new;
        my $str   = $cg->hidden(%$p);

	# Check if hidden return only one line
        my $count = () = $str =~ /input/g;
        if ($count > 1) {
	   $err++;
	   next;
	}

	# Check if input line has proper values
        $str =~ s/\<input\s+//;
        $str =~ s/\/>//;
        my %th = map { split("=") } split(" ", $str);
        is(delete $th{type}, '"hidden"', "Type");
        is(delete $th{name}, '"name_set"', "name");
        is(delete $th{class}, '"class_set"', "class");
        is(delete $th{id}, '"id_set"', "class");
        is(delete $th{value}, '""', "value");
        is(keys %th, 0, "keys");
    }
    ok($err == 0, "Check hash_param");
}

for (1 .. 10) {
    _test();
}
