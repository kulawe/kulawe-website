package Validation::ContextSpecificStrings;

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

sub _initialize
{
    my $this = shift;
}

sub validateName
{
    my $this = shift;
    my ($name) = @ARG;
    # strip any leading or trailing white space
    $name = $this->stripLeadingAndTrailingWhiteSpace($name);
    if ($name =~ m/[\d\n\t\f\e\a\r\\\/\?\.\,\~\#\@\'\:\;\]\}\[\{\+\=\_\)\(\*\&\^\%\$\£\"\!\`\¬\|\<\>]+/ix)
    {
        undef $name;
        return $name;
    }
    elsif ($name =~ m/\s*([A-Za-z\- ]+)/ix)
    {
        $name = $1;
    }
    else
    {
        print STDERR "else catch all\n";
        undef $name;
    }
    return $name;
}

sub validateSubject()
{
    my $this = shift;
    my ($subject) = @ARG;
    # strip any leading or trailing white space
    $subject = $this->stripLeadingAndTrailingWhiteSpace($subject);
    if ($subject =~ m/[\n\t\f\e\a\r\`]+/ix)
    {
        undef $subject;
        return $subject;
    }
    elsif ($subject =~ m/\s*([A-Za-z\w \-\\\/\?\.\,\~\#\@\'\:\;\]\}\[\{\+\=\_\)\(\*\&\^\%\$\£\"\!\¬\|\<\>]+)/ix)
    {
        $subject = $1;
    }
    else
    {
        undef $subject;
    }
    return $subject;
}

sub validateMessage()
{
    my $this = shift;
    my ($message) = @ARG;
    # strip any leading or trailing white space
    $message = $this->stripLeadingAndTrailingWhiteSpace($message);
    if ($message =~ m/[\f\e\a\`]+/ix)
    {
        undef $message;
        return $message;
    }
    elsif ($message =~ m/\s*([A-Za-z\w \-\\\/\?\.\,\~\#\@\'\:\;\]\}\[\{\+\=\_\)\(\*\&\^\%\$\£\"\!\¬\|\n\r\t\<\>]+)/ix)
    {
        $message = $1;
    }
    else
    {
        undef $message;
    }
    return $message;
}

sub stripLeadingAndTrailingWhiteSpace()
{
    my $this = shift;
    my ($string) = @ARG;
    $string =~ s/(?:^\s+)||(?:\s+$)//g;
    return $string;
}

1;
