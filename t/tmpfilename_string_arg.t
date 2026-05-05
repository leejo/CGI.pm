#!perl

# tmpFileName($string) must not die when a non-file form param happens to
# have a value equal to $string. The legacy lookup branch iterates multi_param
# values and must skip non-Fh values before attempting ->filename on them.

use strict;
use warnings;

use Test::More;
use CGI qw/ :cgi /;
$CGI::LIST_CONTEXT_WARN = 0;

my %myenv;

BEGIN {
    %myenv = (
        'REQUEST_METHOD' => 'POST',
        'CONTENT_TYPE'   => 'application/x-www-form-urlencoded',
    );

    for my $key (keys %myenv) {
        $ENV{$key} = $myenv{$key};
    }
}

END {
    for my $key (keys %myenv) {
        delete $ENV{$key};
    }
}

my $q;
{
    my $body = 'title=foo.txt';
    local $ENV{CONTENT_LENGTH} = length($body);
    local *STDIN;
    open STDIN, '<', \$body or die $!;
    $q = CGI->new;
}

is( $q->param('title'), 'foo.txt', 'param value populated as expected' );

my $tmp = eval { $q->tmpFileName('foo.txt') };
ok( !$@, 'tmpFileName($string) does not die when a non-file param matches' )
    or diag("error: $@");
is( $tmp, '', 'tmpFileName($string) returns empty string when no Fh matches' );

done_testing();
