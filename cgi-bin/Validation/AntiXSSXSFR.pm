package Validation::AntiXSSXSFR;

use strict;
use English;
use CGI;

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
    $this->{escaper} = CGI->new;
}

sub htmlEscape()
{
    my $this = shift;
    my ($string) = @ARG;
    return $this->{escaper}->escapeHTML($string);
}

sub scrubScriptTags()
{
    my $this = shift;
    my ($string) = @ARG;
    $string =~ s{
        (<|\&lt;)\s*script\s*(>|\&gt;)
        .*?
        (<|\&lt;)\s*/\s*script\s*(>|\&gt;)
    } []gsxi;
    return $string;
}

sub scrubHTMLEscapes()
{
    my $this = shift;
    my ($string) = @ARG;
    $string =~ s/&([a-zA-z]{2,}|\#\d+);/ /gsxi;
    return $string;
}

sub scrubString
{
    my $this = shift;
    my ($string) = @ARG;
    $string = $this->htmlEscape($string);
    $string = $this->scrubScriptTags($string);
    $string = $this->scrubHTMLEscapes($string);
    return $string;
}

1;
