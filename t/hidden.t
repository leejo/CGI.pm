#!perl -w

use Test::More 'no_plan';
use CGI;

my $q = CGI->new;

# Tests for RT20436
is( $q->hidden( 'hidden_name', 'foo' ),
    qq(<input type="hidden" name="hidden_name" value="foo"  />),
    'hidden() with default value');
is( $q->hidden( 'hidden_name', qw(foo bar baz fie) ),
    qq(<input type="hidden" name="hidden_name" value="foo"  /><input type="hidden" name="hidden_name" value="bar"  /><input type="hidden" name="hidden_name" value="baz"  /><input type="hidden" name="hidden_name" value="fie"  />),
    'hidden() with default array');
is( $q->hidden( -name=>'hidden_name',
            -Values =>[qw/foo bar baz fie/],
            -Title => "hidden_field"),
     qq(<input type="hidden" name="hidden_name" value="foo" title="hidden_field" /><input type="hidden" name="hidden_name" value="bar" title="hidden_field" /><input type="hidden" name="hidden_name" value="baz" title="hidden_field" /><input type="hidden" name="hidden_name" value="fie" title="hidden_field" />),
    'hidden() with named params');

