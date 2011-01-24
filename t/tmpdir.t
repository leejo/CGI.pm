#!perl
use Test::More tests => 5;
use strict;

my ($testdir, $testdir2);

BEGIN {
 $testdir = "CGItest";
 $testdir2 = "CGItest2";
 for ($testdir, $testdir2) {
 ( -d ) || mkdir;
 ( ! -w ) || chmod 0700, $_;
 }
 $CGITempFile::TMPDIRECTORY = $testdir;
 $ENV{TMPDIR} = $testdir2;
}

use CGI;
is($CGITempFile::TMPDIRECTORY, $testdir, "can pre-set \$CGITempFile::TMPDIRECTORY");
CGITempFile->new;
is($CGITempFile::TMPDIRECTORY, $testdir, "\$CGITempFile::TMPDIRECTORY unchanged");

chmod 0500, $testdir;
CGITempFile->new;
is($CGITempFile::TMPDIRECTORY, $testdir2,
 "unwritable \$CGITempFile::TMPDIRECTORY overridden");

chmod 0500, $testdir2;
CGITempFile->new;
isnt($CGITempFile::TMPDIRECTORY, $testdir2,
 "unwritable \$ENV{TMPDIR} overridden");
isnt($CGITempFile::TMPDIRECTORY, $testdir,
 "unwritable \$ENV{TMPDIR} not overridden with an unwritable \$CGITempFile::TMPDIRECTORY");

END { rmdir for ($testdir, $testdir2) }
