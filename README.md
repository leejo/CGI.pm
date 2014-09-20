[![Build Status](https://travis-ci.org/leejo/CGI.pm.svg?branch=master)](https://travis-ci.org/leejo/CGI.pm)

## WHAT IS THIS?

This is CGI.pm, an easy-to-use Perl5 library for writing CGI scripts.

## CGI.pm HAS BEEN REMOVED FROM THE PERL CORE

	http://perl5.git.perl.org/perl.git/commitdiff/e9fa5a80

If you upgrade to a new version of perl or if you rely on a
system or vendor perl and get an updated version of perl through a system
update, then you will have to install CGI.pm yourself with cpan/cpanm/a vendor
package/manually. To make this a little easier the CGI::Fast module has been
split into its own distribution, meaning you do not need acces to a compiler
to install CGI.pm

The rational for this decision is that CGI.pm is no longer considered good
practice for developing web applications, B<including> quick prototyping and
small web scripts. There are far better, cleaner, quicker, easier, safer,
more scalable, more extensible, more modern alternatives available at this point
in time. These will be documented with a specific CPAN dist: CGI::Alternatives.

For more discussion on the removal of CGI.pm from core please see:

http://www.nntp.perl.org/group/perl.perl5.porters/2013/05/msg202130.html

## HOW DO I INSTALL IT?

To install this module, cd to the directory that contains this README
file and type the following:

   perl Makefile.PL
   make
   make test
   make install

## WHAT SYSTEMS DOES IT WORK WITH?

This module works with Linux, Windows, OSX, FreeBSD, VMS and other platforms.

## WHERE IS THE DOCUMENTATION?

Documentation is found in POD (plain old documentation) form in CGI.pm
itself.  When you install CGI, manaul pages will automatically be installed.
on Unix systems, type "man CGI" or "perldoc CGI").

## WHERE ARE THE EXAMPLES?

A collection of examples demonstrating various CGI features and techniques are
in the directory "examples". These are now rather old examples of Perl code and
should not be considered as best practices.

## WHERE IS THE ONLINE DOCUMENTATION?

Online documentation of for CGI.pm, and notifications of new versions
can be found at:

   http://search.cpan.org/dist/CGI.pm/

## WHERE CAN I VIEW OR SUBMIT BUGS / ISSUES / REQUESTS / CONTRIBUTE?

The new bug tracker can be found on github:

   https://github.com/leejo/CGI.pm/issues

Existing issues have been migrated from rt.cpan.org:

   https://rt.cpan.org/Dist/Display.html?Name=CGI
   https://rt.cpan.org/Dist/Display.html?Queue=CGI.pm

These tickets are still considered active, they will be closed when
the issues on github are closed.

If you would like to contribute then please comment on issues, raise
issues, pull requests, etc.

## WHERE CAN I LEARN MORE?

Lincoln Stein wrote a book about CGI.pm called "The Official Guide to
Programming with CGI.pm" which was published by John Wiley & Sons in
May 1998.
