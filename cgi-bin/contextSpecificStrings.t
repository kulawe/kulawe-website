#!/usr/bin/perl -w

use Test::Simple tests => 21;
use Validation::ContextSpecificStrings;

$q = Validation::ContextSpecificStrings->new;

$dirtyString = "owen Waller"; 
$cleanString = "owen Waller";
$result = $q->validateName($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'Good name Validated');

$dirtyString = "   owen Waller"; 
$cleanString = "owen Waller";
$result = $q->validateName($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'leading white space name Validated');

$dirtyString = "owen"; 
$cleanString = "owen";
$result = $q->validateName($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'single word name Validated');

$dirtyString = "robert owen waller"; 
$cleanString = "robert owen waller";
$result = $q->validateName($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'multi word name Validated');

$dirtyString = "owen-waller"; 
$cleanString = "owen-waller";
$result = $q->validateName($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'hyphenated name Validated');

$dirtyString = "owen-waller"; 
$cleanString = "owen-waller";
$result = $q->validateName($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'hyphenated name Validated');

$dirtyString = "123owen-waller"; 
$result = $q->validateName($dirtyString); 
ok(!defined($result), 'names with numbers rejected');

$dirtyString = "owe123n-waller"; 
$result = $q->validateName($dirtyString); 
ok(!defined($result), 'names with numbers rejected');

$dirtyString = "owen\$@!\"\£\(\}:',. waller"; 
$result = $q->validateName($dirtyString); 
ok(!defined($result), 'names punchuation symbols rejected');

$dirtyString = "owen\t\r\ewaller"; 
$result = $q->validateName($dirtyString); 
ok(!defined($result), 'names escaped symbols rejected');

$dirtyString = "This is a good subject line (2012/11/5)!"; 
$cleanString = "This is a good subject line (2012/11/5)!";
$result = $q->validateSubject($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'good subject validated');

$dirtyString = "bad\t\nSubj\ect"; 
$result = $q->validateSubject($dirtyString); 
ok(!defined($result), 'bad subject rejected');

$dirtyString = "This is a good Message &^%&*^( line (2012/11/5)!"; 
$cleanString = "This is a good Message &^%&*^( line (2012/11/5)!";
$result = $q->validateMessage($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'good Message validated');

$dirtyString = "This is a good\n Message &^%&*^( line (2012/11/5)!"; 
$cleanString = "This is a good\n Message &^%&*^( line (2012/11/5)!";
$result = $q->validateMessage($dirtyString); 
ok(defined($result) && $result eq $cleanString, 'good Message with embedded newline validated');

$dirtyString = "bad\t\nM\ess\ag\e"; 
$result = $q->validateMessage($dirtyString); 
ok(!defined($result), 'bad message rejected');

$dirtyString = "   leading White space";
$cleanString = "leading White space";
$result = $q->stripLeadingAndTrailingWhiteSpace($dirtyString);
ok($result eq $cleanString, "leading white space stripped");

$dirtyString = "trailing White space     ";
$cleanString = "trailing White space";
$result = $q->stripLeadingAndTrailingWhiteSpace($dirtyString);
ok($result eq $cleanString, "trailing white space stripped");

# look for the null string case
$dirtyString = "";
$cleanString = "";
$result = $q->stripLeadingAndTrailingWhiteSpace($dirtyString);
ok($result eq $cleanString, "Empty string case, returns an empty string.");

# look for a no argument case
$result = $q->stripLeadingAndTrailingWhiteSpace();
ok($result eq "", "No argument case. Retutrned an empty string.");

# look for the numeric zero case
$result = $q->stripLeadingAndTrailingWhiteSpace(0);
ok($result eq "0", "\"0\" argument case. Returned \"0\"");

# pass an undefined value
$result = $q->stripLeadingAndTrailingWhiteSpace($undefinedValue);
ok($result eq "", "Undefined value case");
