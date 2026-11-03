#!perl

# cookie attribute values are not escaped, so path/domain/expires must not
# accept ";" or control characters - which allowed other attributes to be
# injected when an app passed request data (e.g. path_info) to them

use strict;
use warnings;

use Test::More;
use CGI;
use CGI::Cookie;

$CGI::LIST_CONTEXT_WARN = 0;

my @bad = (
    '/shop; Domain=example.com',
    "/shop\r\nSet-Cookie: evil=1",
    "/a\x00b",
    "/a\tb",
);

for my $value ( @bad ) {
    ( my $label = $value ) =~ s/([^\x20-\x7e])/sprintf('\\x%02x',ord $1)/ge;

    eval { CGI::Cookie->new( -name => 'a', -value => 1, -path => $value ) };
    like( $@, qr/Invalid cookie path/, "path '$label' is rejected by new()" );

    my $c = CGI::Cookie->new( -name => 'a', -value => 1 );
    eval { $c->path( $value ) };
    like( $@, qr/Invalid cookie path/, ' ... and by path()' );
    is( $c->path, '/', ' ... leaving the path unchanged' );

    eval { CGI->new('')->cookie( -name => 'a', -value => 1, -path => $value ) };
    like( $@, qr/Invalid cookie path/, ' ... and by CGI->cookie()' );

    eval { CGI::Cookie->new( -name => 'a', -value => 1, -expires => $value ) };
    like( $@, qr/Invalid cookie expires/, " ... as is expires '$label'" );
}

for my $domain ( '.example.com; SameSite=None', 'example.com/x', 'exa mple.com', "example.com\r\n", 'example.com,evil.com' ) {
    ( my $label = $domain ) =~ s/([^\x20-\x7e])/sprintf('\\x%02x',ord $1)/ge;
    eval { CGI::Cookie->new( -name => 'a', -value => 1, -domain => $domain ) };
    like( $@, qr/Invalid cookie domain/, "domain '$label' is rejected" );
}

# expires passed through CGI::Util::expires unchanged if it isn't a time
eval { CGI::Cookie->new( -name => 'a', -value => 1, -expires => '1; Domain=.example.com' ) };
like( $@, qr/Invalid cookie expires/, 'expires of "1; Domain=.example.com" is rejected' );

# valid values are fine
my $c = CGI::Cookie->new(
    -name     => 'a',
    -value    => [ 'x;y', 'z' ], # the value is escaped
    -path     => '/shop/cart-items/a.b~c,d=e',
    -domain   => '.Shop-1.example_host.com',
    -expires  => 'Thu, 01 Jan 2032 00:00:00 GMT',
    -samesite => 'Strict',
);
is( $c->as_string,
    'a=x%3By&z; domain=.shop-1.example_host.com; path=/shop/cart-items/a.b~c,d=e; expires=Thu, 01 Jan 2032 00:00:00 GMT; SameSite=Strict',
    'valid attributes are unchanged' );

for my $expires ( 'now', '+1d', '-3M', '+180s', 0 ) {
    my $c = eval { CGI::Cookie->new( -name => 'a', -value => 1, -expires => $expires ) };
    is( $@, '', "expires '$expires' is accepted" );
    like( $c && $c->expires, qr/\A\w{3}, \d{2} \w{3} \d{4} \d{2}:\d{2}:\d{2} GMT\z/, ' ... as a date' );
}

done_testing();
