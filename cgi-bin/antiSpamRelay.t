#!/usr/bin/perl -w

use Test::Simple tests => 5;
use Validation::AntiSpamRelay;

$q = Validation::AntiSpamRelay->new;

$dirtyString = 'some random To: string'; 
$cleanString = 'some random  string';
ok($q->antiSpam($dirtyString) eq $cleanString, 'To: email header cleaned');

$dirtyString = "newline\nstring"; 
$cleanString = "newline string";
ok($q->antiSpam($dirtyString) eq $cleanString, 'Newline removed from string');

$dirtyString = "multi-escape \r\r \estri \a ng"; 
$cleanString = "multi-escape    stri  ng";
ok($q->antiSpam($dirtyString) eq $cleanString, 'Multiple escapes removed from string');

$dirtyString = "single tab\tstring"; 
$cleanString = "single tab string";
ok($q->antiSpam($dirtyString) eq $cleanString, 'Single Tab removed from string');

$dirtyString = "multi tab\t\tstring"; 
$cleanString = "multi tab string";
ok($q->antiSpam($dirtyString) eq $cleanString, 'Multi Tab removed from string');


