use ExtUtils::MakeMaker;
my $mm = $ExtUtils::MakeMaker::VERSION;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    INSTALLDIRS      => ( $] >= 5.012 ? 'site' : 'perl' ),
    ABSTRACT_FROM    => 'lib/CGI.pod',
    VERSION_FROM     => 'lib/CGI.pm',
    NAME             => 'CGI',
    DISTNAME         => 'CGI',
    LICENSE          => 'perl_5',
    VERSION_FROM     => 'lib/CGI.pm',
    MIN_PERL_VERSION => '5.8.1',
    PREREQ_PM        => {
        'Carp'           => 0,     # Carp was first released with perl 5
        'Exporter'       => 0,     # Exporter was first released with perl 5
        'base'           => 0,     # base was first released with perl 5.00405
        'overload'       => 0,     # overload was first released with perl 5.002
        'strict'         => 0,     # strict was first released with perl 5
        'utf8'           => 0,     # utf8 was first released with perl v5.6.0
        'warnings'       => 0,     # warnings was first released with perl v5.6.0
        'File::Spec'     => 0.82,
        'if'             => 0,     # core in 5.6.2 and later, for deprecate.pm
        'parent'         => 0.225, # parent was first released with perl v5.10.1
        'File::Temp'     => 0,     # was first released with perl v5.6.1'
        'HTML::Entities' => 3.69,
        'Encode'         => 0,    # Encode was first released with perl v5.7.3
        'Config'         => 0,    # Config was first released with perl 5.00307
    },
    TEST_REQUIRES   => {
        'Cwd'              => 0,     # Cwd was first released with perl 5
        'POSIX'            => 0,    # POSIX was first released with perl 5
        'IO::File'         => 0,    # IO::File was first released with perl 5.00307
        'IO::Handle'       => 0,    # IO::Handle was first released with perl 5.00307
        'File::Find'       => 0,    # File::Find was first released with perl 5
        'Test::Deep'       => 0.11,
        'Test::More'       => 0.98,
        'Test::Warn'       => 0.30,
        'Test::NoWarnings' => 1.04,
    },
    test    => { TESTS    => 't/*.t t/headers/*.t' },
    linkext => { LINKTYPE => '' }, # no link needed
    dist  => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
        ZIP      => '/usr/bin/zip',
        ZIPFLAGS => '-rl'
    },
    (
        $mm < 6.46
        ? ()
        : (
            META_MERGE => {
                requires  => { perl => '5.008001' },
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    homepage   => 'https://metacpan.org/module/CGI',
                    repository => 'https://github.com/leejo/CGI.pm',
                    bugtracker => 'https://github.com/leejo/CGI.pm/issues',
                },
                no_index => { directory => [qw/t/] },
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),
);
