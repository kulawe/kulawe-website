#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use CGI::Carp;
use CGI::Carp qw(carpout);
use CGI::Carp qw(fatalsToBrowser);

BEGIN 
{
    use CGI::Carp qw(carpout);
    open(LOG, ">>../logs/mycgi-log") or
    die("Unable to open mycgi-log: $!\n");
    carpout(\*LOG);
}

my $q = CGI->new;


# check $ENV has the referer header set and tht it contains the URL of the
# contact form. This should stop an external party copying the form contents
# and calling the script from an unauthorised domain.
sub checkRefererHeader()
{
    my $KulaweContactFormUrl = "http://kulawe.com";
    if(defined $ENV{'HTTP_REFERER'})
    {
        print STDERR "HTTP_REFERER is set\n";
    }
    else
    {
        print STDERR "HTTP_REFERER is NOT defined\n";
    }
    if(defined $ENV{'HTTP_REFERER'} && $ENV{'HTTP_REFERER'} == $KulaweContactFormUrl)
    {
        warn("HTTP_REFERER set to " . $ENV{'HTTP_REFERER'});
    }
    else
    {
        warn("Referer header not set.\n");
    }
}
 
# send a redirect
my(@pythonloc) = `ls -l /usr/bin/`;
print STDERR @pythonloc;
print STDERR "Message to STDERR\n\n";
#checkRefererHeader();
my ($key);
foreach $key (sort keys %ENV)
{
    print STDERR "$key => $ENV{$key}\n";
}

# this is a redirect header.
print STDERR $q->header(-location => 'http://www.kulawe.com/test/contact-form-success');
die("This is a die line, the script will stop here....");
