package CGI::Carp;

=head1 NAME

B<CGI::Carp> - CGI routines for writing to the HTTPD (or other) error log

=head1 SYNOPSIS

    use CGI::Carp;

    croak "We're outta here!";
    confess "It was my fault: $!";
    carp "It was your fault!";   
    warn "I'm confused";
    die  "I'm dying.\n";

    use CGI::Carp qw(cluck);
    cluck "I wouldn't do that if I were you";

    use CGI::Carp qw(fatalsToBrowser);
    die "Fatal error messages are now sent to browser";

=head1 DESCRIPTION

CGI scripts have a nasty habit of leaving warning messages in the error
logs that are neither time stamped nor fully identified.  Tracking down
the script that caused the error is a pain.  This fixes that.  Replace
the usual

    use Carp;

with

    use CGI::Carp

And the standard warn(), die (), croak(), confess() and carp() calls
will automagically be replaced with functions that write out nicely
time-stamped messages to the HTTP server error log.

For example:

   [Fri Nov 17 21:40:43 1995] test.pl: I'm confused at test.pl line 3.
   [Fri Nov 17 21:40:43 1995] test.pl: Got an error message: Permission denied.
   [Fri Nov 17 21:40:43 1995] test.pl: I'm dying.

=head1 REDIRECTING ERROR MESSAGES

By default, error messages are sent to STDERR.  Most HTTPD servers
direct STDERR to the server's error log.  Some applications may wish
to keep private error logs, distinct from the server's error log, or
they may wish to direct error messages to STDOUT so that the browser
will receive them.

The C<carpout()> function is provided for this purpose.  Since
carpout() is not exported by default, you must import it explicitly by
saying

   use CGI::Carp qw(carpout);

The carpout() function requires one argument, which should be a
reference to an open filehandle for writing errors.  It should be
called in a C<BEGIN> block at the top of the CGI application so that
compiler errors will be caught.  Example:

   BEGIN {
     use CGI::Carp qw(carpout);
     open(LOG, ">>/usr/local/cgi-logs/mycgi-log") or
       die("Unable to open mycgi-log: $!\n");
     carpout(LOG);
   }

carpout() does not handle file locking on the log for you at this point.

The real STDERR is not closed -- it is moved to CGI::Carp::SAVEERR.  Some
servers, when dealing with CGI scripts, close their connection to the
browser when the script closes STDOUT and STDERR.  CGI::Carp::SAVEERR is there to
prevent this from happening prematurely.

You can pass filehandles to carpout() in a variety of ways.  The "correct"
way according to Tom Christiansen is to pass a reference to a filehandle 
GLOB:

    carpout(\*LOG);

This looks weird to mere mortals however, so the following syntaxes are
accepted as well:

    carpout(LOG);
    carpout(main::LOG);
    carpout(main'LOG);
    carpout(\LOG);
    carpout(\'main::LOG');

    ... and so on

FileHandle and other objects work as well.

Use of carpout() is not great for performance, so it is recommended
for debugging purposes or for moderate-use applications.  A future
version of this module may delay redirecting STDERR until one of the
CGI::Carp methods is called to prevent the performance hit.

=head1 MAKING PERL ERRORS APPEAR IN THE BROWSER WINDOW

If you want to send fatal (die, confess) errors to the browser, ask to 
import the special "fatalsToBrowser" subroutine:

    use CGI::Carp qw(fatalsToBrowser);
    die "Bad error here";

Fatal errors will now be echoed to the browser as well as to the log.  CGI::Carp
arranges to send a minimal HTTP header to the browser so that even errors that
occur in the early compile phase will be seen.  (As of version 1.27, CGI::Carp
will check if the CGI module is loaded, and if so, use it to generate the header.)
Nonfatal errors will still be directed to the log file only (unless redirected
with carpout).

=head2 Changing the default message

By default, the software error message is followed by a note to
contact the Webmaster by e-mail with the time and date of the error.
If this message is not to your liking, you can change it using the
set_message() routine.  This is not imported by default; you should
import it on the use() line:

    use CGI::Carp qw(fatalsToBrowser set_message);
    set_message("It's not a bug, it's a feature!");

You may also pass in a code reference in order to create a custom
error message.  At run time, your code will be called with the text
of the error message that caused the script to die.  Example:

    use CGI::Carp qw(fatalsToBrowser set_message);
    BEGIN {
        set_message sub {
            my $msg = shift;
            print "<h1>Oh gosh</h1>";
            print "<p>Got an error: $msg</p>";
        };
    }

In order to correctly intercept compile-time errors, you should call
set_message() from within a BEGIN{} block.

Normally CGI::Carp will send HTTP headers to the browser even if you
provide your own error handler.  If you wish to disable this feature,
you may call the suppress_header() function with a true argument.

=head1 MAKING WARNINGS APPEAR AS HTML COMMENTS

It is now also possible to make non-fatal errors appear as HTML
comments embedded in the output of your program.  To enable this
feature, export the new "warningsToBrowser" subroutine.  Since sending
warnings to the browser before the HTTP headers have been sent would
cause an error, any warnings are stored in an internal buffer until
you call the warningsToBrowser() subroutine with a true argument:

    use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
    use CGI qw(:standard);
    print header();
    warningsToBrowser(1);

You may also give a false argument to warningsToBrowser() to prevent
warnings from being sent to the browser while you are printing some
content where HTML comments are not allowed:

    warningsToBrowser(0);    # disable warnings
    print "<script type=\"text/javascript\"><!--\n";
    print_some_javascript_code();
    print "//--></script>\n";
    warningsToBrowser(1);    # re-enable warnings

Note: In this respect warningsToBrowser() differs fundamentally from
fatalsToBrowser(), which you should never call yourself!

=head1 OVERRIDING THE NAME OF THE PROGRAM

CGI::Carp includes the name of the program that generated the error or
warning in the messages written to the log and the browser window.
Sometimes, Perl can get confused about what the actual name of the
executed program was.  In these cases, you can override the program
name that CGI::Carp will use for all messages.

The quick way to do that is to tell CGI::Carp the name of the program
in its use statement.  You can do that by adding
"name=cgi_carp_log_name" to your "use" statement.  For example:

    use CGI::Carp qw(name=cgi_carp_log_name);

.  If you want to change the program name partway through the program,
you can use the C<set_progname()> function instead.  It is not
exported by default, you must import it explicitly by saying

    use CGI::Carp qw(set_progname);

Once you've done that, you can change the logged name of the program
at any time by calling

    set_progname(new_program_name);

You can set the program back to the default by calling

    set_progname(undef);

Note that this override doesn't happen until after the program has
compiled, so any compile-time errors will still show up with the
non-overridden program name
  
=head1 CHANGE LOG

1.05 carpout() added and minor corrections by Marc Hedlund
     <hedlund@best.com> on 11/26/95.

1.06 fatalsToBrowser() no longer aborts for fatal errors within
     eval() statements.

1.08 set_message() added and carpout() expanded to allow for FileHandle
     objects.

1.09 set_message() now allows users to pass a code REFERENCE for 
     really custom error messages.  croak and carp are now
     exported by default.  Thanks to Gunther Birznieks for the
     patches.

1.10 Patch from Chris Dean (ctdean@cogit.com) to allow 
     module to run correctly under mod_perl.

1.11 Changed order of &gt; and &lt; escapes.

1.12 Changed die() on line 217 to CORE::die to avoid B<-w> warning.

1.13 Added cluck() to make the module orthogonal with Carp.
     More mod_perl related fixes.

1.20 Patch from Ilmari Karonen:  Added warningsToBrowser().  Replaced
     <CODE> tags with <PRE> in fatalsToBrowser() output.

1.23 ineval() now checks both $^S and inspects the message for the "eval"
     pattern (hack alert!) in order to accomodate various combinations of
     Perl and mod_perl.

1.24 Patch from Scott Gifford (sgifford@suspectclass.com): Add support
     for overriding program name.

1.26 Replaced CORE::GLOBAL::die with the evil $SIG{__DIE__} because the
     former isn't working in some people's hands.  There is no such thing
     as reliable exception handling in Perl.

1.27 Patch from Ilmari Karonen:  Added suppress_header(), mostly rewrote
     fatalsToBrowser() for clarity.  fatalsToBrowser now checks if CGI.pm
     is in use and uses it to generate headers if so.  warningsToBrowser()
     should now work under mod_perl (not tested).

=head1 AUTHORS

Copyright 1995-2002, Lincoln D. Stein.  All rights reserved.  

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Address bug reports and comments to: lstein@cshl.org

=head1 SEE ALSO

Carp, CGI::Base, CGI::BasePlus, CGI::Request, CGI::MiniSvr, CGI::Form,
CGI::Response

=cut

require 5.000;
use Exporter;
#use Carp;
BEGIN { 
  require Carp; 
  *CORE::GLOBAL::die = \&CGI::Carp::die;
}

use File::Spec;
use CGI::Util qw(escape);

@ISA = qw(Exporter);
@EXPORT = qw(confess croak carp);
@EXPORT_OK = qw(carpout fatalsToBrowser warningsToBrowser wrap set_message suppress_header set_progname cluck ^name= die);

$main::SIG{__WARN__}=\&CGI::Carp::warn;

$CGI::Carp::VERSION    = '1.28';
$CGI::Carp::CUSTOM_MSG = undef;
$CGI::Carp::DELAYED_WARNINGS = "";

# fancy import routine detects and handles 'errorWrap' specially.
sub import {
    my $pkg = shift;
    my(%routines);
    my(@name);
  
    if (@name=grep(/^name=/,@_))
      {
        my($n) = (split(/=/,$name[0]))[1];
        set_progname($n);
        @_=grep(!/^name=/,@_);
      }

    grep($routines{$_}++,@_,@EXPORT);
    $WRAP++ if $routines{'fatalsToBrowser'} || $routines{'wrap'};
    $WARN++ if $routines{'warningsToBrowser'};
    my($oldlevel) = $Exporter::ExportLevel;
    $Exporter::ExportLevel = 1;
    Exporter::import($pkg,keys %routines);
    $Exporter::ExportLevel = $oldlevel;
    $main::SIG{__DIE__} =\&CGI::Carp::die if $routines{'fatalsToBrowser'};
#    $pkg->export('CORE::GLOBAL','die');
}

# These are the originals
sub realwarn { CORE::warn(@_); }
sub realdie { CORE::die(@_); }

sub id {
    my $level = shift;
    my($pack,$file,$line,$sub) = caller($level);
    my($dev,$dirs,$id) = splitpath($file);
    return ($file,$line,$id);
}

sub stamp {
    my $time = scalar(localtime);
    my $frame = 0;
    my ($id,$pack,$file,$dev,$dirs);
    if (defined($CGI::Carp::PROGNAME)) {
        $id = $CGI::Carp::PROGNAME;
    } else {
        do {
  	  $id = $file;
	  ($pack,$file) = caller($frame++);
        } until !$file;
    }
    ($dev,$dirs,$id) = splitpath($id);
    return "[$time] $id: ";
}

sub set_progname {
    $CGI::Carp::PROGNAME = shift;
    return $CGI::Carp::PROGNAME;
}

sub splitpath {
  my $path = shift;
  if (UNIVERSAL::can('File::Spec','splitpath')) {
    return File::Spec->splitpath($path);
  }
  else {
    return split '/',$path;
  }
}


sub warn {
    my $message = shift;
    my($file,$line,$id) = id(1);
    $message .= " at $file line $line.\n" unless $message=~/\n$/;
    _warn(mangle_warning($message)) if $WARN;
    my $stamp = stamp;
    $message=~s/^/$stamp/gm;
    realwarn $message;
}

sub _warn {
    my $msg = shift;
    if (!$EMIT_WARNINGS) {
        $DELAYED_WARNINGS .= $msg;
    } elsif (exists $ENV{MOD_PERL}) {
        Apache->request->print($msg);
    } else {
        print STDOUT $msg;
    }
}

sub mangle_warning {
    my $msg = shift;
    # We need to mangle the message a bit to make it a valid HTML
    # comment.  This is done by substituting similar-looking ISO
    # 8859-1 characters for <, > and -.  This is a hack.
    $msg =~ tr/<>-/\253\273\255/;
    chomp $msg;
    return "<!-- warning: $msg -->\n";
}

# The mod_perl package Apache::Registry loads CGI programs by calling
# eval.  These evals don't count when looking at the stack backtrace.
sub _longmess {
    my $message = Carp::longmess();
    $message =~ s,eval[^\n]+(ModPerl|Apache)/Registry\w*\.pm.*,,s
        if exists $ENV{MOD_PERL};
    return $message;
}

sub ineval {
  (exists $ENV{MOD_PERL} ? 0 : $^S) || _longmess() =~ /eval [\{\']/m
}

sub die {
  my ($arg) = @_;
  realdie @_ if ineval;
  if (!ref($arg)) {
    $arg = join("", @_);
    my($file,$line,$id) = id(1);
    $arg .= " at $file line $line." unless $arg=~/\n$/;
    &fatalsToBrowser($arg) if $WRAP;
    if (($arg =~ /\n$/) || !exists($ENV{MOD_PERL})) {
      my $stamp = stamp;
      $arg=~s/^/$stamp/gm;
    }
    if ($arg !~ /\n$/) {
      $arg .= "\n";
    }
  }
  realdie $arg;
}

sub set_message {
    $CGI::Carp::CUSTOM_MSG = shift;
}

sub suppress_header {
    $CGI::Carp::NO_HEADER = (@_ ? shift : 1);
}

sub confess { CGI::Carp::die Carp::longmess @_; }
sub croak   { CGI::Carp::die Carp::shortmess @_; }
sub carp    { CGI::Carp::warn Carp::shortmess @_; }
sub cluck   { CGI::Carp::warn Carp::longmess @_; }

# We have to be ready to accept a filehandle as a reference
# or a string.
sub carpout {
    my($in) = @_;
    my($no) = fileno(to_filehandle($in));
    realdie("Invalid filehandle $in\n") unless defined $no;
    
    open(SAVEERR, ">&STDERR");
    open(STDERR, ">&$no") or 
	( print SAVEERR "Unable to redirect STDERR: $!\n" and exit(1) );
}

sub warningsToBrowser {
    if ($EMIT_WARNINGS = @_ ? shift : 1) {
        _warn $DELAYED_WARNINGS if length($DELAYED_WARNINGS);
        $DELAYED_WARNINGS = "";
    }
}

# headers
sub fatalsToBrowser {
    my $msg = shift;
    _htmlescape($msg);

    my $mod_perl = exists $ENV{MOD_PERL};
    my $no_header = $mod_perl || $NO_HEADER || eval {
        # This trick might work on some setups, but not always.
        my $bytes_sent = tell(STDOUT);
        defined($bytes_sent) && $bytes_sent > 0;
    };
      
    # First we send the CGI header.  If the CGI module is available,
    # we use that, otherwise we create a simple header ourselves.
    
    unless ($no_header) {
        if ($CGI::VERSION) {
            print STDOUT CGI::header(-status => "500 Software error");
        } else {
            print STDOUT <<END;
Status: 500 Software error
Content-type: text/html

END
        }
    }
    
    # If the user has provided an error handler, we execute it and
    # return.  Presumably the handler knows what to do.

    &$CUSTOM_MSG($msg), return  if ref($CUSTOM_MSG) eq 'CODE';

    # If the user didn't provide a custom explanatory message, we create
    # one.  We try to include the webmaster's email address if possible.

    my $outer_message = $CUSTOM_MSG;
    if (!$outer_message) {
        my $wm = "this site's webmaster";
        if ($ENV{SERVER_ADMIN}) {
            my $admin = $ENV{SERVER_ADMIN};
            my $mailto = "mailto:" . escape($admin);
            _htmlescape($admin, $mailto);
            $wm = qq[the webmaster (<a href="$mailto">$admin</a>)];
        }
        $outer_message = <<END;
For help, please send mail to $wm, giving this error message 
and the time and date of the error.
END
    }

    # Next we wrap the error and the explanatory message in some simple
    # HTML.  We also include any delayed warnings.

    my $message = $DELAYED_WARNINGS . <<END;
<h1>Software error:</h1>
<pre>$msg</pre>
<p>$outer_message</p>
END
    $DELAYED_WARNINGS = "";

    # MSIE won't display a custom 500 response unless it is >512 bytes!
    $message .= "<!-- " . ' ' x (512-length($message)) . " -->\n"
        if $ENV{HTTP_USER_AGENT} && $ENV{HTTP_USER_AGENT} =~ /\bMSIE\b/;

    # Finally the message is sent to the browser.  This takes some extra
    # code if we're under mod_perl, otherwise we just send it to STDOUT.

    if ($mod_perl) {
        require mod_perl;
        if ($mod_perl::VERSION >= 1.99) {
            $mod_perl = 2;
            require Apache::RequestRec;
            require Apache::RequestIO;
            require Apache::RequestUtil;
            require APR::Pool;
            require ModPerl::Util;
            require Apache::Response;
        }
        my $r = Apache->request;
        
        # If bytes have already been sent, then we print the message out
        # directly.  Otherwise we make a custom error handler to produce
        # the doc for us.

        if ($r->bytes_sent) {
            $r->print($message);
            $mod_perl == 2 ? ModPerl::Util::exit(0) : $r->exit;
        } else {
            $r->custom_response(500, $message);
        }
    } else {
        print STDOUT $message;
    }
}

sub _htmlescape {
    for (@_) {
        s/&/&amp;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
        s/\"/&quot/g;
    }
}

# Cut and paste from CGI.pm so that we don't have the overhead of
# always loading the entire CGI module.
sub to_filehandle {
    my $thingy = shift;
    return undef unless $thingy;
    return $thingy if UNIVERSAL::isa($thingy,'GLOB');
    return $thingy if UNIVERSAL::isa($thingy,'FileHandle');
    if (!ref($thingy)) {
	my $caller = 1;
	while (my $package = caller($caller++)) {
	    my($tmp) = $thingy=~/[\':]/ ? $thingy : "$package\:\:$thingy"; 
	    return $tmp if defined(fileno($tmp));
	}
    }
    return undef;
}

1;
