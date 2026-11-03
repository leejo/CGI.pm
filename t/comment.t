#!perl

# comment() text must not be able to end the comment and inject markup

use strict;
use warnings;

use Test::More;
use HTML::Parser;
use CGI qw/ comment /;

# what a browser would see: comments end at the first -->
sub parsed {
    my ( $html ) = @_;
    my @events;
    my $p = HTML::Parser->new(
        api_version => 3,
        handlers    => { default => [ sub { push @events, $_[0] unless $_[0] =~ /^(?:start|end)_document$/ }, 'event' ] },
    );
    $p->parse( $html );
    $p->eof;
    return \@events;
}

is( comment('here is my comment'), '<!-- here is my comment -->', 'plain text is unchanged' );
is( comment( 'a', 'b' ), '<!-- a b -->', 'multiple args are joined with spaces' );
is( comment('a - b'), '<!-- a - b -->', 'single dashes are unchanged' );
is( CGI->new('')->comment('oo'), '<!-- oo -->', 'works as a method too' );

for my $text (
    '1 --><script>alert(1)</script>',
    '1 --!><script>alert(1)</script>',
    '<!-- nested --> <script>alert(1)</script>',
    'x--->y', 'x---->y', '-->', '--', '---', '-', '>', '->', '<!-',
) {
    my $html = comment( $text );
    my ( $inner ) = $html =~ /\A<!-- (.*) -->\z/s;
    ok( defined $inner, "comment('$text') is a single comment: $html" );
    is_deeply( parsed( $html ), [ 'comment' ], ' ... when parsed as HTML' );
    unlike( defined $inner ? $inner : '', qr/--/, ' ... with no -- inside it' );
    ( my $squashed = defined $inner ? $inner : '' ) =~ s/ //g;
    ( my $expect = $text ) =~ s/ //g;
    is( $squashed, $expect, ' ... and only spaces added to the text' );
}

done_testing();
