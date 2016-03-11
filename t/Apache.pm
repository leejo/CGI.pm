package Apache;

sub request {
	return bless( {},shift );
}

sub bytes_sent { 0 };
sub custom_response { $ENV{MOD_PERL_PRINTED} = $_[2] };

1;
