#!/bin/perl

use strict;

my (%hash);
my ($key, $value);
$key = "fruit";
$value = "banana";

$hash{$key} = $value;

my ($key);
foreach $key (sort keys %hash)
{
    print STDERR "$key => $hash{$key}\n";
}
