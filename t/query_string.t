#!perl

# Tests for the query_string() method.

use lib 't/lib';
use Test::More 'no_plan';
use CGI;

{
    my $q1 = CGI->new('a=1;b=2');
    my $q2 = CGI->new('b=2&a=1');

    is($q1->query_string
        ,$q2->query_string
        , "query string format is reliable");
}
