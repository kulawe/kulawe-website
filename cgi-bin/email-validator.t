#!/usr/bin/perl -w

use Test::Simple tests => 3;
use Validation::EmailAddress;

$q = Validation::EmailAddress->new;

$dirtyString = 'o.waller@kulawe.com';
$cleanString = 'o.waller@kulawe.com';
$result = $q->validateEmail($dirtyString);
ok(defined($result) && $result eq $cleanString, 'kulawe Email address valid');

ok(defined $q->validateEmail('owenwaller@googlemail.com'), 'googlemail Email address valid');

ok(defined $q->validateEmail('owenwaller@hotmail.com'), 'hotmail Email address valid');

