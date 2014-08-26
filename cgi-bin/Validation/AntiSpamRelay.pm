package Validation::AntiSpamRelay;

use strict;
use English;

sub new
{
    my $class = shift;
    my $this = {};
    bless $this, $class;
    $this->_initialize();
    return $this;
}

sub _initialize()
{
    my $this = shift;
}

sub antiSpam()
{
    my $this = shift;
    my ($cleanText) = @ARG;
    # wipe excessive white space esp. new lines that can be used to inject email headers
    $cleanText =~ s/[\f|\e|\a]+//gix;
    # swap tabs for a space
    $cleanText =~ s/\n|\r|\t+/ /gix;
    # wipe danderous email headers
    $cleanText =~ s/(To|From|Bcc|Cc|Reply-To|Sender)://gix;
    return $cleanText;    
}

1;
