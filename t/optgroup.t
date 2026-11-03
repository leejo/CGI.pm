#!perl
# Tests for optgroup();
use strict;
use warnings;

use Test::More;
use CGI;

is(
    CGI::optgroup( -name => 'g', -values => [ 'a', 'b' ] ),
    qq{<optgroup label="g">\n<option value="a">a</option>\n<option value="b">b</option>\n</optgroup>},
    'optgroup(): values'
);

is(
    CGI::optgroup( -name => 'g', -values => [ 'a', 'b' ], -labels => { a => 'A' } ),
    qq{<optgroup label="g">\n<option value="a">A</option>\n<option value="b">b</option>\n</optgroup>},
    'optgroup(): labels'
);

is(
    CGI::optgroup( -name => 'g', -values => [ 'a', 'b' ], -labeled => 1 ),
    qq{<optgroup label="g">\n<option label="a" value="a">a</option>\n<option label="b" value="b">b</option>\n</optgroup>},
    'optgroup(): -labeled'
);

# -novals was documented but ignored
is(
    CGI::optgroup( -name => 'g', -values => [ 'a', 'b' ], -novals => 1 ),
    qq{<optgroup label="g">\n<option>a</option>\n<option>b</option>\n</optgroup>},
    'optgroup(): -novals suppresses the value attribute'
);

is(
    CGI::optgroup( -name => 'g', -values => [ 'a', 'b' ], -labeled => 1, -novals => 1 ),
    qq{<optgroup label="g">\n<option label="a">a</option>\n<option label="b">b</option>\n</optgroup>},
    'optgroup(): -labeled and -novals'
);

# a nested optgroup is passed through as is
my $inner = CGI::optgroup( -name => 'inner', -values => [ 'x' ] );
is(
    CGI::optgroup( -name => 'outer', -values => [ 'a', $inner ] ),
    qq{<optgroup label="outer">\n<option value="a">a</option>\n$inner\n</optgroup>},
    'optgroup(): nested optgroup is passed through'
);

{
    # it used to try to mark a value selected using an unset $CGI::selected,
    # interpolated (unquoted) into a regex
    no warnings 'once';
    local $CGI::selected = '(';
    my $html = eval { CGI::optgroup( -name => 'outer', -values => [ $inner ] ) };
    is( $@, '', 'a stray $CGI::selected is not used as a pattern' );
    unlike( defined $html ? $html : '', qr/selected/, ' ... nor marks anything selected' );
}

done_testing();
