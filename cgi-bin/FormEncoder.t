#!/usr/bin/perl -w

use Test::Simple tests => 12;
use Test::Exception;
use Validation::FormEncoder;

$q = Validation::FormEncoder->new;

$dirtyString = "path/separator.."; 
$cleanString = "pathseparator";
$result = $q->scrubPathSeparators($dirtyString); 
ok($result eq $cleanString, "/ and .. scrubbed");

$dirtyString = "....4Dots"; 
$cleanString = "4Dots";
$result = $q->scrubPathSeparators($dirtyString); 
ok($result eq $cleanString, ".... scrubbed");

$dirtyString = ".1Dot"; 
$cleanString = ".1Dot";
$result = $q->scrubPathSeparators($dirtyString); 
ok($result eq $cleanString, "1 dot left");

$dirtyString = "...3Dots"; 
$cleanString = ".3Dots";
$result = $q->scrubPathSeparators($dirtyString); 
ok($result eq $cleanString, "3 dots to 1 dot");


$dirtyString = "//2Slashes"; 
$cleanString = "2Slashes";
$result = $q->scrubPathSeparators($dirtyString); 
ok($result eq $cleanString, "// scrubbed");

$dirtyString = "\x00-\x08\x0B-\x1F\x7F"; 
$cleanString = "--";
$result = $q->scrubASCIIBinary($dirtyString); 
ok($result eq $cleanString, "ascii binary scrubbed");

$dirtyString = "\t\x00-\x08\x0B-\x1F\x7F\n"; 
$cleanString = "\t--\n";
$result = $q->scrubASCIIBinary($dirtyString); 
ok($result eq $cleanString, "ascii binary scrubbed - tabs new line preserved");

$dirtyString = "\x09\x00-\x08\x0B-\x1F\x7F\x0A"; 
$cleanString = "\x09--\x0A";
$result = $q->scrubASCIIBinary($dirtyString); 
ok($result eq $cleanString, "ascii binary scrubbed - tabs new line (in hex) preserved");

# all key values must be defined, otherwise we should die
my %formContents = (
    'name' => 'N',
    'email' => 'E',
    'subject' => 'S',
    'message' => 'M',
    ); 

my %expectedFieldNames;
%expectedFieldNames = (
    'name' => 'name',
    'email' => 'email',
    'subject' => 'subject',
    'message' => 'message',
    );
# undefine the name
$formContents{undef} = 'N';
delete $formContents{'name'};
throws_ok {$q->dieIfKeysNotCorrect(\%formContents, \%expectedFieldNames)} qr/Aborting/, "Undefined name key caught ok";

# the key names must all be as expected, otherwise we should die
delete $formContents{undef};
$formContents{'banana'} = 'Banana';
throws_ok {$q->dieIfKeysNotCorrect(\%formContents, \%expectedFieldNames)} qr/Aborting/, "Unexpected key name caught";

# test too few keys
delete $formContents{'banana'};
throws_ok {$q->dieIfKeysNotCorrect(\%formContents, \%expectedFieldNames)} qr/Aborting/, "Too few keys caught";

# test too many keys
$formContents{'name'} = 'N';
$formContents{'extra'} = 'extra';
my @keys = keys %formContents;
print $#keys;
throws_ok {$q->dieIfKeysNotCorrect(\%formContents, \%expectedFieldNames)} qr/More/, "Too many keys caught";


