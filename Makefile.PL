use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
my %WriteMakefileArgs = (
    INSTALLDIRS      => ( "$]" >= 5.011 ? 'site' : 'perl' ),
    ABSTRACT_FROM    => 'lib/CGI.pod',
    VERSION_FROM     => 'lib/CGI.pm',
    NAME             => 'CGI',
    DISTNAME         => 'CGI',
    LICENSE          => 'artistic_2',
    VERSION_FROM     => 'lib/CGI.pm',
    MIN_PERL_VERSION => '5.8.1',
    PREREQ_PM        => {
        'Carp'           => 0,     # Carp was first released with perl 5
        'Exporter'       => 0,     # Exporter was first released with perl 5
        'overload'       => 0,     # overload was first released with perl 5.002
        'strict'         => 0,     # strict was first released with perl 5
        'utf8'           => 0,     # utf8 was first released with perl v5.6.0
        'warnings'       => 0,     # warnings was first released with perl v5.6.0
        'File::Spec'     => 0.82,
        'if'             => 0,     # core in 5.6.2 and later, for deprecate.pm
        'parent'         => 0.225, # parent was first released with perl v5.10.1
        'File::Temp'     => 0.17,  # 0.17 for seekable file handles
        'HTML::Entities' => 3.69,
        'Encode'         => 0,    # Encode was first released with perl v5.7.3
        'Config'         => 0,    # Config was first released with perl 5.00307
        'URI'            => 1.76,
    },
    TEST_REQUIRES   => {
        'Cwd'              => 0,     # Cwd was first released with perl 5
        'POSIX'            => 0,    # POSIX was first released with perl 5
        'IO::File'         => 0,    # IO::File was first released with perl 5.00307
        'IO::Handle'       => 0,    # IO::Handle was first released with perl 5.00307
        'File::Find'       => 0,    # File::Find was first released with perl 5
        'Test::More'       => 0.98,
        'Test::Warn'       => 0.30,
        'Test::NoWarnings' => 0,
    },
    test    => { TESTS    => 't/*.t t/headers/*.t' },
    linkext => { LINKTYPE => '' }, # no link needed
    dist  => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
        ZIP      => '/usr/bin/zip',
        ZIPFLAGS => '-rl',
		TARFLAGS => '-c -v --no-xattrs -f',
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        requires    => { perl    => '5.008001' },
        resources   => {
            license    => 'http://dev.perl.org/licenses/',
            homepage   => 'https://metacpan.org/module/CGI',
            repository => {
                url  => 'https://github.com/leejo/CGI.pm',
                web  => 'https://github.com/leejo/CGI.pm',
                type => 'git',
            },
            bugtracker => {
                web => 'https://github.com/leejo/CGI.pm/issues',
            }
        },
        no_index => { directory => [qw/t/] },
    },
);

unless ( eval { ExtUtils::MakeMaker->VERSION(6.64) } ) {
	my $req = delete $WriteMakefileArgs{'TEST_REQUIRES'};
	@{ $WriteMakefileArgs{'BUILD_REQUIRES'} }{ keys %$req } = values %$req;
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.5503) } ) {
	my $req = delete $WriteMakefileArgs{'BUILD_REQUIRES'};
	@{ $WriteMakefileArgs{'PREREQ_PM'} }{ keys %$req } = values %$req;
}

delete $WriteMakefileArgs{'MIN_PERL_VERSION'}
	unless eval { ExtUtils::MakeMaker->VERSION(6.48) };

delete $WriteMakefileArgs{'META_MERGE'}
	unless eval { ExtUtils::MakeMaker->VERSION(6.46) };

delete $WriteMakefileArgs{'LICENSE'}
	unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);
