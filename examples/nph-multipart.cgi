#!/usr/local/bin/perl
use CGI qw/:push -nph/;
$| = 1;
print multipart_init(-boundary=>'----------------here we go!',-charset=>'utf-8');
while (1) {
    print multipart_start(-type=>'text/plain',-charset=>'utf-8'),
    "The current time is ",scalar(localtime),"\n",
    multipart_end;
    sleep 1;
}
