#!/bin/perl -w

use strict;
use Test::More tests => 5;
use CGI qw /a start_html/;

# Test that constructs fed from hashes generate unchanging HTML output

# HTML Attributes within tags
is(a({-href=>'frog',-alt => 'Frog'},'frog'),'<a alt="Frog" href="frog">frog</a>',"sorted attributes 1");
is(a({-href=>'frog',-alt => 'Frog', -frog => 'green'},'frog'),'<a alt="Frog" frog="green" href="frog">frog</a>',"sorted attributes 2");
is(a({-href=>'frog',-alt => 'Frog', -frog => 'green', -type => 'water'},'frog'),'<a alt="Frog" frog="green" href="frog" type="water">frog</a>',"sorted attributes 3");

# List of meta attributes in the HTML header
my %meta = (
	'frog1' => 'frog1',
	'frog2' => 'frog2',
	'frog3' => 'frog3',
	'frog4' => 'frog4',
	'frog5' => 'frog5',
);

is(join("",grep (/frog\d/,split("\n",start_html( -meta => \%meta )))),
'<meta name="frog1" content="frog1" /><meta name="frog2" content="frog2" /><meta name="frog3" content="frog3" /><meta name="frog4" content="frog4" /><meta name="frog5" content="frog5" />',
"meta tags are sorted alphabetically by name 1");

$meta{'frog6'} = 'frog6';
is(join("",grep (/frog\d/,split("\n",start_html( -meta => \%meta )))),
'<meta name="frog1" content="frog1" /><meta name="frog2" content="frog2" /><meta name="frog3" content="frog3" /><meta name="frog4" content="frog4" /><meta name="frog5" content="frog5" /><meta name="frog6" content="frog6" />',
"meta tags are sorted alphabetically by name 2");
