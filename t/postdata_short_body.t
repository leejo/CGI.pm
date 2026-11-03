#!perl

# a request body shorter than CONTENT_LENGTH must not cause
# read_postdata_putdata to spin forever, including when uploads
# are disabled

use strict;
use warnings;

use Test::More;
use CGI;

plan skip_all => "alarm not available on $^O" if $^O eq 'MSWin32';

my $body = 'short body';

for my $method ( qw/ POST PUT PATCH / ) {
    for my $disable_uploads ( 1, 0 ) {

        CGI::initialize_globals();
        $CGI::PUTDATA_UPLOAD  = 1;
        $CGI::DISABLE_UPLOADS = $disable_uploads;

        local $ENV{REQUEST_METHOD} = $method;
        local $ENV{CONTENT_TYPE}   = 'application/octet-stream';
        local $ENV{CONTENT_LENGTH} = length( $body ) + 1000;
        local $ENV{QUERY_STRING}   = '';

        local *STDIN;
        open STDIN, '<', \$body or die "In-memory filehandle failed\n";

        my $label = "$method with DISABLE_UPLOADS=$disable_uploads";

        my $q = eval {
            local $SIG{ALRM} = sub { die "timeout\n" };
            alarm 10;
            my $cgi = CGI->new;
            alarm 0;
            $cgi;
        };
        alarm 0;

        isnt( $@, "timeout\n", "$label: short body does not spin" );
        like( $@, qr/Server closed socket during read_postdata_putdata/, " ... dies with expected error" );
    }
}

done_testing();
