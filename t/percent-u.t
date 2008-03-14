#
# This tests %uXXXX notation
# -- dankogai
BEGIN {
    if ($] < 5.008) {
       print "1..0 # \$] == $] < 5.008\n";
       exit(0);
    }
}
use strict;
use warnings;
use Encode;
use Test::More tests => 6;
use utf8;
use CGI::Util;

my %escaped = (
	       encode_utf8(chr(0x61))    => '%u0061',
	       encode_utf8(chr(0x5F3E))  => '%u5F3E',
	       encode_utf8(chr(0x2A6B2)) => '%uD869%uDEB2',
);

for my $chr (keys %escaped){
    is  !utf8::is_utf8($chr), 1;
    is CGI::Util::unescape($escaped{$chr}), $chr, "$escaped{$chr} => $chr";
}
__END__
