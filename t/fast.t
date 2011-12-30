#!perl -w

my $fcgi;
BEGIN {
    local $@;
    eval { require FCGI };
    $fcgi = $@ ? 0 : 1;
}

use Test::More tests => 9;

# Shut up "used only once" warnings.
() = $CGI::Q;

SKIP: {
    skip( 'FCGI not installed, cannot continue', 9 ) unless $fcgi;

    require CGI::Fast;
    ok( my $q = CGI::Fast->new(), 'created new CGI::Fast object' );
    is( $q, $CGI::Q, 'checking to see if the object was stored properly' );
    is( $q->param(), (), 'no params' );

    ok( $q = CGI::Fast->new({ foo => 'bar' }), 'creating object with params' );
    is( $q->param('foo'), 'bar', 'checking passed param' );

    is($CGI::PRIVATE_TEMPFILES,0, "reality check default value for CGI::PRIVATE_TEMPFILES");
    import CGI::Fast '-private_tempfiles';
    CGI::Fast->new;
    is($CGI::PRIVATE_TEMPFILES,1, "pragma in subclass set package variable in parent class. ");
    $q = CGI::Fast->new({ a => 1 });
    ok($q, "reality check: something was returned from CGI::Fast->new besides undef");
    is($CGI::PRIVATE_TEMPFILES,1, "package variable in parent class persists through multiple calls to CGI::Fast->new ");

};
