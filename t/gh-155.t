use strict;
use warnings;
use Test::More;

use CGI;

for (1 .. 20) {
    my $q = CGI->new;

    my %args = (
        '-charset'      => 'UTF-8',
        '-type'         => 'text/html',
        '-content-type' => 'text/html; charset=iso-8859-1',
    );

    like(
		$q->header(%args),
		qr!Content-Type: text/html; charset=iso-8859-1!,
		'favour content type over charset/type'
	);
}

done_testing();
