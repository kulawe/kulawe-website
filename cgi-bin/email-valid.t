#!/usr/bin/perl -w

use Test::Simple tests => 3;

use Email::Valid;
$q = Email::Valid->new;

ok($q->address(-address => 'o.waller@kulawe.com',
                        -mxcheck => 1,
                        -tldcheck => 1,
                        -allow_ip => 0), 'kulawe Email address valid');

ok($q->address(-address => 'owenwaller@googlemail.com',
                        -mxcheck => 1,
                        -tldcheck => 1,
                        -allow_ip => 0), 'googlemail Email address valid');

ok($q->address(-address => 'owenwaller@hotmail.com',
                        -mxcheck => 1,
                        -tldcheck => 1,
                        -allow_ip => 0), 'hotmail Email address valid');

