#!perl
# Tests for scrolling_list();
use strict;
use warnings;

use Test::More;
use CGI;

is(
    CGI::scrolling_list(-values=>[CGI::optgroup(-values=>["b+"])],-default=>"b+"),
    '<select name=""  size="1">
<optgroup label="">
<option selected="selected" value="b+">b+</option>
</optgroup>
</select>'
    , "<optgroup> selections work when the default values contain regex characters (RT#49606)");

# selected values come from the request params, so are client supplied
# and must never be interpolated into a pattern
my $optgroup = CGI::optgroup(-name=>'g', -values=>['a', '(', 'b+']);

for my $selected ( '(', '[', '\\', '.*', '(a|aa)*\1b' ) {
    my $q = CGI->new({ sel => $selected });
    my $html = eval { $q->scrolling_list(-name=>'sel', -values=>[$optgroup]) };
    is( $@, '', "scrolling_list does not die with selected param: $selected" );
    like( $html, qr{^<select name="sel"}, ' ... and returns the list' );
}

{
    my $q    = CGI->new({ sel => '(' });
    my $html = $q->scrolling_list(-name=>'sel', -values=>[$optgroup]);
    like( $html, qr{<option selected="selected" value="\(">}, 'selected param with regex characters is selected literally' );
    unlike( $html, qr{selected="selected" value="(?:a|b\+)"}, ' ... and nothing else is selected' );
}

{
    my $q    = CGI->new({ sel => '.*' });
    my $html = $q->scrolling_list(-name=>'sel', -values=>[$optgroup]);
    unlike( $html, qr{selected="selected"}, 'selected param .* does not select every option' );
}

SKIP: {
    skip "alarm not available on $^O", 1 if $^O eq 'MSWin32';
    my $og = CGI::optgroup(-name=>'g', -values=>[ 'a' x 40 ]);
    my $q  = CGI->new({ sel => '(a|aa|aaa)*\1b' });
    eval {
        local $SIG{ALRM} = sub { die "timeout\n" };
        alarm 10;
        $q->scrolling_list(-name=>'sel', -values=>[$og]);
        alarm 0;
    };
    alarm 0;
    is( $@, '', 'pathological selected param is not executed as a pattern' );
}

done_testing();
