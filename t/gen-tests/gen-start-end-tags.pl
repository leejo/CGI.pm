#!/usr/bin/perl -w

use strict;

my @tags = 
    (
        "h1","h2","h3","h4","h5","h6",
        "table","ul","li","ol","td",
        "b","i","u","div",
    );

my $the_tag;
my $tests_body = "";
my $num_tests = 0;
foreach $the_tag (@tags)
{
    my $start_or_end;
    foreach $start_or_end (qw(start end))
    {
        my $slash = ($start_or_end eq "start") ? "" : "/";
        $tests_body .= "is(${start_or_end}_${the_tag}(), \"<${slash}${the_tag}>\", \"${start_or_end}_${the_tag}\"); # TEST\n";
        $num_tests++;
        if ($start_or_end eq "start")
        {
            $tests_body .= "is(${start_or_end}_${the_tag}({class => 'hello'}), \"<${slash}${the_tag} class=\\\"hello\\\">\", \"${start_or_end}_${the_tag} with param\"); # TEST\n";
            $num_tests++;
        }
    }
    $tests_body .= "\n";
}

my $header1 = <<"EOF";
#!/usr/local/bin/perl -w

use lib qw(t/lib);
use strict;

# Due to a bug in older versions of MakeMaker & Test::Harness, we must
# ensure the blib's are in \@INC, else we might use the core CGI.pm
use lib qw(blib/lib blib/arch);
EOF
;

my $header2 = "use Test::More tests => $num_tests;\n\n";

my $header3;

sub write_file
{
    my %args = (@_);
    local(*O);
    open O, ">t/start_end_" . $args{'filename'} . ".t\n";
    my $content = $header1 . $header2 .
        "use CGI qw(:standard " .
            join(" ", @{$args{'use_params'}}) . ");\n\n" .
        $tests_body;
    print O $content;
    close(O);
}

write_file(
    "filename" => "asterisk",
    "use_params" => [ map {"\*$_" } @tags ],
);

write_file(
    "filename" => "start",
    "use_params" => [ map {"start_$_"} @tags],
);

write_file(
    "filename" => "end",
    "use_params" => [ map {"end_$_"} @tags],
);

