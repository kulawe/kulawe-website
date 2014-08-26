#!/usr/bin/perl -w

use Test::Simple tests => 7;
use Validation::AntiXSSXSFR;

$q = Validation::AntiXSSXSFR->new;

$dirtyString = "<script>alert(\"XSS\");</script>"; 
$cleanString = "&lt;script&gt;alert(&quot;XSS&quot;);&lt;/script&gt;";
ok($q->htmlEscape($dirtyString) eq $cleanString, 'HTML script tags escaped.');

$dirtyString = "<?php echo 'Hello World'; ?>";
$cleanString = "&lt;?php echo &#39;Hello World&#39;; ?&gt;";
ok($q->htmlEscape($dirtyString) eq $cleanString, 'PHP script tags escaped.');


$dirtyString = "<script>alert(\"XSS\");</script>"; 
$cleanString = "";
print $q->scrubScriptTags($dirtyString); 
ok($q->scrubScriptTags($dirtyString) eq $cleanString, 'script tags scrubbed.');


$dirtyString = "<script>alert(\"XSS\");</script>"; 
$dirtyString = $q->htmlEscape($dirtyString);
$cleanString = "";
print $q->scrubScriptTags($dirtyString); 
ok($q->scrubScriptTags($dirtyString) eq $cleanString, 'script tags scrubbed - HTML escaped case');


$dirtyString = "&lt;script&gt;alert(&quot;XSS&quot;);&lt;/script&gt;";
$cleanString = " script alert( XSS ); /script ";
ok($q->scrubHTMLEscapes($dirtyString) eq $cleanString, 'HTML escaped codes scrubbed.');

$dirtyString = "&lt;?php echo &#39;Hello World&#39;; ?&gt;";
$cleanString = " ?php echo  Hello World ; ? ";
ok($q->scrubHTMLEscapes($dirtyString) eq $cleanString, 'PHP script tags escaped.');

$dirtyString = "<script>alert(\"XSS\");</script>"; 
$cleanString = "";
ok($q->scrubString($dirtyString) eq $cleanString, 'script tags scrubbed.');
