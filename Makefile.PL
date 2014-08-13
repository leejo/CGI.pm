use ExtUtils::MakeMaker;
my $mm = $ExtUtils::MakeMaker::VERSION;

require 5.008001;

system("perl", "t/gen-tests/gen-start-end-tags.pl");

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
'INSTALLDIRS' => ( $] >= 5.012 ? 'site' : 'perl' ),
    'NAME'	=> 'CGI',
    'DISTNAME'  => 'CGI',
    'VERSION_FROM'   => 'lib/CGI.pm',
     'PREREQ_PM' => {
       'if'          => 0, # core in 5.6.2 and later, for deprecate.pm
       'Test::More'  => 0.98, # Ideally, this could be just a "test_requires". Version requirement is for 'subtest' support.
       'Test::Deep'  => 0.11,
       'File::Spec'  => .82,
    },
    test => { TESTS => 't/*.t t/headers/*.t' },
    'linkext'   => { LINKTYPE=>'' },	# no link needed
    'dist'      => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
	            'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
   (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008001'},
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    homepage => 'https://metacpan.org/module/CGI',
                    repository => 'https://github.com/leejo/CGI.pm',
                    bugtracker => 'https://github.com/leejo/CGI.pm/issues',
                },
                no_index => {directory => [qw/t/]},
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),


);

