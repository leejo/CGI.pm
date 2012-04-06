use ExtUtils::MakeMaker;
my $mm = $ExtUtils::MakeMaker::VERSION;

require 5.6.0;

system("perl", "t/gen-tests/gen-start-end-tags.pl");

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
'INSTALLDIRS' => 'perl',
    'NAME'	=> 'CGI',
    'DISTNAME'  => 'CGI.pm',
    'VERSION_FROM'   => 'lib/CGI.pm',
     'PREREQ_PM' => {
       'Test::More'  => 0.98, # Ideally, this could be just a "test_requires". Version requirement is for 'subtest' support.
       'File::Spec'  => .82,
       'FCGI'        => 0.67,
    },
    test => { TESTS => 't/*.t t/headers/*.t' },
    'linkext'   => { LINKTYPE=>'' },	# no link needed
    'dist'      => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
	            'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'},
   (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.006000'},
                resources => {
                    # homepage => 'http://FIXME.org',
                    # license  => 'http://dev.perl.org/licenses/',
                    # MailingList => 'http://FIXME',
                    repository => 'http://github.com/markstos/CGI.pm/tree/master'
                },
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),


);

