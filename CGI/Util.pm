package CGI::Util;

use strict;
use vars '$VERSION','@EXPORT','@ISA';
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(rearrange make_attributes);

$VERSION = '1.0';

# Smart rearrangement of parameters to allow named parameter
# calling.  We do the rearangement if:
# the first parameter begins with a -
sub rearrange {
    my($order,@param) = @_;
    return () unless @param;

    if (ref($param[0]) eq 'HASH') {
	@param = %{$param[0]};
    } else {
	return @param 
	    unless (defined($param[0]) && substr($param[0],0,1) eq '-');
    }

    # map parameters into positional indices
    my ($i,%pos);
    $i = 0;
    foreach (@$order) {
	foreach (ref($_) eq 'ARRAY' ? @$_ : $_) { $pos{$_} = $i; }
	$i++;
    }

    my (@result,%leftover);
    $#result = $#$order;  # preextend
    while (@param) {
	my $key = uc(shift(@param));
	$key =~ s/^\-//;
	if (exists $pos{$key}) {
	    $result[$pos{$key}] = shift(@param);
	} else {
	    $leftover{$key} = shift(@param);
	}
    }

    push (@result,make_attributes(\%leftover)) if %leftover;
    @result;
}

sub make_attributes {
    my $attr = shift;
    return () unless $attr && ref($attr) && ref($attr) eq 'HASH';
    my(@att);
    foreach (keys %{$attr}) {
	my($key) = $_;
	$key=~s/^\-//;     # get rid of initial - if present
	$key=~tr/a-z_/A-Z-/; # parameters are upper case, use dashes
	push(@att,defined($attr->{$_}) ? qq/$key="$attr->{$_}"/ : qq/$key/);
    }
    return @att;
}

1;
