use ExtUtils::MakeMaker;
require 5.6.0;

system("perl", "t/gen-tests/gen-start-end-tags.pl");

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'INSTALLDIRS' => 'perl',
    'NAME'	=> 'CGI',
    'DISTNAME'  => 'CGI.pm',
    'VERSION_FROM'   => 'CGI.pm',
     'PREREQ_PM' => {
       'File::Spec'  => .82,
    },
    'linkext'   => { LINKTYPE=>'' },	# no link needed
    'dist'      => {'COMPRESS'=>'gzip -9f', 'SUFFIX' => 'gz',
	            'ZIP'=>'/usr/bin/zip','ZIPFLAGS'=>'-rl'}
);

