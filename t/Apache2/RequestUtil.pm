package Apache2::RequestUtil;

sub request {
	return bless( {},shift );
}

sub bytes_sent { 1 };
sub print { $ENV{MOD_PERL_PRINTED} = $_[1] };
sub exit {};

1;
