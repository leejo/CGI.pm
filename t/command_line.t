#!/usr/local/bin/perl
# Test running CGI from the command line (typically used for debugging).

use strict;
use warnings;

use File::Temp qw(tempfile);

use Test::More tests => 10;
use Test::Deep;
use Test::NoWarnings;

# We don't need to import CGI here since it's the perl subprocess that loads it.

my $loaded = 1;

$| = 1;

######################### End of black magic.

my @cmd_base = ($^X);
push @cmd_base, "-I$_" foreach @INC;
push @cmd_base, '-MCGI', '-e';

# Run a string of Perl code using a command line CGI invocation.
# Takes the code and any additional command line arguments.
# Dies if any error or warnings; returns stdout.
#
sub run {
    die 'pass code snippet, optional args' if not @_;
    my @cmd = (@cmd_base, @_);
    my ($stdout_fh, $stdout_filename) = tempfile;
    my ($stderr_fh, $stderr_filename) = tempfile;
    open my $old_stdout, '>&STDOUT' or die "cannot dup stdout: $!";
    open my $old_stderr, '>&STDERR' or die "cannot dup stderr: $!";
    open STDOUT, '>&', $stdout_fh or die "cannot redirect stdout: $!";
    open STDERR, '>&', $stderr_fh or die "cannot redirect stderr: $!";
    my $r = system(@cmd);
    my $system_status = $?;
    open STDOUT, '>&', $old_stdout or die "cannot restore stdout: $!";
    open STDERR, '>&', $old_stderr or die "cannot restore stderr: $!";
    close $stdout_fh or die "cannot close $stdout_filename: $!";
    close $stderr_fh or die "cannot close $stderr_filename: $!";

    if ($r) {
        die <<END
failed to run: @cmd
system() status code is $system_status
stdout is in $stdout_filename
stderr is in $stderr_filename
END
;
    }

    open my $got_stdout_fh, '<', $stdout_filename or die "cannot read $stdout_filename: $!";
    open my $got_stderr_fh, '<', $stderr_filename or die "cannot read $stderr_filename: $!";
    my $got_stdout = do { local $/; <$got_stdout_fh> };
    my $got_stderr = do { local $/; <$got_stderr_fh> };
    unlink $stdout_filename or die "cannot unlink $stdout_filename: $!";
    unlink $stderr_filename or die "cannot unlink $stderr_filename: $!";

    if ($got_stderr ne '') {
        die <<END
ran, but produced warnings: @cmd
stderr is:
$got_stderr
stdout is:
$got_stdout
END
;
    }

    return $got_stdout;

}

my $arg = 'game=chess&game=checkers&weather=dull';



# Test ordinary functionality.
is run('print CGI::header()'), "Content-Type: text/html; charset=ISO-8859-1\r\n\r\n", 'header';
is run('print CGI::h1("hi")'), '<h1>hi</h1>', 'h1';

# Test that request_method returns undef as documented.
is run('$r = CGI::request_method(); print defined $r ? 1 : 0'), '0', 'request_method is undef';

# Now test parameter fetching.  url_param should work the same as param.
foreach my $fn (qw(param url_param)) {
    is run(sprintf('$r = CGI::%s("game"); print $r', $fn), $arg), 'chess', "get first $fn";
    is run(sprintf('@p = CGI::%s(); print scalar @p', $fn), $arg), 2, "number of ${fn}s";
    is run(sprintf('@p = CGI::%s(); @p = sort @p; print "@p"', $fn), $arg), 'game weather', "names of ${fn}s";
}
