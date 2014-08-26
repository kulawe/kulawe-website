package Validation::EmailAddress;

use strict;
use English;
use Email::Valid;

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
    $this->{validator} = Email::Valid->new;
}

sub validateEmail()
{
    my $this = shift;
    my ($address) = @ARG;
    warn("Attempoting to validate address: \"$address\"");
    my $screenedAddress = undef;
    eval
    {
        $screenedAddress = $this->{validator}->address(-address => $address,
                        -mxcheck => 1,
                        -tldcheck => 1,
                        -allow_ip => 0)
    };
    if($EVAL_ERROR)
    {
        warn("an error was encountered: $EVAL_ERROR. Possibly no mx recordfor the domain...");
    }
  return $screenedAddress
}

1;
