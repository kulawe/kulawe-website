#!/usr/bin/perl -w

use strict;
use English;

local $INPUT_RECORD_SEPARATOR = undef;
open(ERRORPAGE, "../output/contact-form-missing-name/index.html");
my $file = <ERRORPAGE>;
print ("file contains\n\n".$file."\n\n");
my $field = 'name';
my $count = ($file =~ s{<input\ name='$field'\ type='text'>}[<div\ class='error'><input\ name='$field'\ type='text'></div>]gix);
print "count value is: $count\n";

$file =~ s{<textarea\ name='message'.*>}[<div class='error'>$MATCH</div>]gix;
print $MATCH;


print("file NOW contains\n\n".$file."\n\n");
#print "Content-type:text/html\r\n\r\n";
#print $file;
close(ERRORPAGE);
exit(0);    

