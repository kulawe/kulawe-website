package Validation::FormEncoder;

use strict;
use English;
use CGI;
use Encode;
use Validation::AntiXSSXSFR;
use Validation::AntiSpamRelay;
use Log::Log4perl qw(get_logger :levels);

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
    $this->{cgi} = CGI->new;
    $this->{antiXSSXSFR} = Validation::AntiXSSXSFR->new;
    $this->{antiSpam} = Validation::AntiSpamRelay->new;
}

sub getFormContents
{
    my $this = shift;
    my ($key, $value);
    my %formContents = ();
    my %formContentsOctets = (); 
    # strictly %formContentsOctets contains a list of octet pairs. Each
    # pair is a UTF-8 encoded key and value. Both keys and values
    # need to be converted to perls internal string form.
    %formContentsOctets = $this->{cgi}->Vars();
    while (my($keyOctets, $valueOctets) = each(%formContentsOctets)) 
    {
        $key = decode("UTF-8", $keyOctets);
        $value = decode("UTF-8", $valueOctets);
        $formContents{$key} = $value;
    }
    return %formContents;
}

sub scrubContents
{
    my $this = shift;
    my %contents = @ARG;
    my %scrubbedContents = ();  
    my ($key, $value, $scrubbedKey, $scrubbedValue); 
    while (my($key, $value) = each(%contents)) 
    {
        $scrubbedKey = $this->{antiXSSXSFR}->scrubString($key);
        $scrubbedValue = $this->{antiXSSXSFR}->scrubString($value);
        $scrubbedKey = $this->{antiSpam}->antiSpam($scrubbedKey);
        $scrubbedValue = $this->{antiSpam}->antiSpam($scrubbedValue);
        $scrubbedKey = $this->scrubPathSeparators($scrubbedKey);
        $scrubbedValue = $this->scrubPathSeparators($scrubbedValue);
        $scrubbedKey = $this->scrubASCIIBinary($scrubbedKey);
        $scrubbedValue = $this->scrubASCIIBinary($scrubbedValue);        
        $scrubbedContents{$scrubbedKey} = $scrubbedValue;
    }
	my $logger = get_logger("Validation::FormEncoder");    
    foreach $key (sort keys %scrubbedContents)
    {
        $logger->info("FormEncoder: $key => $scrubbedContents{$key}");
    }
    return %scrubbedContents;
}

sub scrubPathSeparators
{
    my $this = shift;
    my ($string) = @ARG;
    $string =~ s/[\/]+//gix;
    $string =~ s/(\.\.)+//gix;
    return $string;
}

sub scrubASCIIBinary
{
    my $this = shift;
    my ($string) = @ARG;
    # strip everything except for a \n (0x0A) and \t (0x09)
    $string =~ s/[\x00-\x08\x0B-\x1F\x7F]//gix;
    return $string;  
}

sub dieIfKeysNotCorrect
{
    my $this = shift;
    my ($formContents, $expectedFieldNames) = @ARG;
    my $key;
    my $expectedName;
	my $logger = get_logger("Validation::FormEncoder");
    # check that each of the field names are defined...
    # if there are less than expected number the loop aborts
    foreach $key (sort keys %$expectedFieldNames)
    {
		$expectedName = $expectedFieldNames->{$key};
		$logger->info("testing key name: \"$expectedName\"");
		if(!defined $formContents->{$expectedName})
		{
	    	$logger->warn("The key \"$expectedName\" is undefined!");
			# grab the User Agent and IP addres of whoever sent this
	 		my $ua = $ENV{'HTTP_USER_AGENT'};
			my $ip = $ENV{'REMOTE_ADDR'};
			$logger->warn("User Agent of the spammer is: $ua");
			$logger->warn("IP of the spammer is: $ip");
        	$logger->logdie("Aborting");
		}
		# if $formContents->{$expectedName} is defined than it must
		# by defination be equal to the expected value i.e the key names match
    }
    # we could have more keys. Abort if we do
    #
    my @expectedKeys = keys %$expectedFieldNames;
    my @keys = keys %$formContents;
    if($#keys > $#expectedKeys)
    {
		$logger->logdie("More keys than expected found. Expecting: " , $#expectedKeys+1 , ", found: " , $#keys+1);
    }
}

1;
