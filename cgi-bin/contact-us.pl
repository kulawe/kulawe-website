#!/usr/bin/perl -w

use strict;
use English;
use lib $ENV{'PWD'};
use CGI;
use CGI::Carp;
use CGI::Carp qw(carpout);
use CGI::Carp qw(fatalsToBrowser);
use diagnostics;
use Log::Log4perl qw(get_logger :levels);

# create a Validator that will extract the UTF-8 encoded
# strings from the web form
use Validation::FormEncoder;
use Validation::ContextSpecificStrings;

BEGIN 
{
    use CGI::Carp qw(carpout);
    open(LOG, ">>../logs/contact-us-log") or
    die("Unable to open contact-us-log: $!\n");
    carpout(\*LOG);
}

END 
{
    use CGI::Carp qw(carpout);
    warn("closing log");
    close(LOG) or
    die("Unable to close contact-us-log: $!\n");
}


use Validation::EmailAddress;

# setup the logger
Log::Log4perl->init("./contact-us-log.conf");

my %expectedFieldNames;
%expectedFieldNames = (
    'name' => 'name',
    'email' => 'email',
    'subject' => 'subject',
    'message' => 'message',
    );

my %exitRedirects;
%exitRedirects = (
    'illegal_email'=> '../contact-form-illegal-email/index.html',
    'illegal_message' => '../contact-form-illegal-message/index.html', 
    'illegal_name' => '../contact-form-illegal-name/index.html',
    'illegal_subject' => '../contact-form-illegal-subject/index.html',
    'missing_email' => '../contact-form-missing-email/index.html',
    'missing_message' => '../contact-form-missing-message/index.html',
    'missing_name' => '../contact-form-missing-name/index.html',
    'missing_subject' => '../contact-form-missing-subject/index.html',
    'internal_error' => 'http://www.kulawe.com/contact-us-error',
    'success' => 'http://www.kulawe.com/contact-form-success',
    );
 
my $cgi = CGI->new;

# get and decode from UTF-8 the form contents 
my ($formEncoder, %formContents);
$formEncoder = Validation::FormEncoder->new;
%formContents = $formEncoder->getFormContents();

# scrub all the key value pairs for dangerous input
%formContents = $formEncoder->scrubContents(%formContents);

   
# check that the keys with the expected names exist
my ($key, $expectedName);
$formEncoder->dieIfKeysNotCorrect(\%formContents, \%expectedFieldNames);

# validate the name or redirect
$formContents{'name'} = validateName($formContents{'name'});
$formContents{'email'} = validateEmail($formContents{'email'});
$formContents{'subject'} = validateSubject($formContents{'subject'});
$formContents{'message'} = validateMessage($formContents{'message'});

redirectIfBadName($cgi, \%formContents, \%exitRedirects, \%expectedFieldNames);
redirectIfBadEmail($cgi, \%formContents, \%exitRedirects, \%expectedFieldNames);
redirectIfBadSubject($cgi, \%formContents, \%exitRedirects, \%expectedFieldNames);
redirectIfBadMessage($cgi, \%formContents, \%exitRedirects, \%expectedFieldNames);

sendEmailOrRedirect(\%formContents, $exitRedirects{'success'}, $exitRedirects{'internal_error'});


sub validateName
{
    my ($name) = @ARG;
    my $stringValidator = Validation::ContextSpecificStrings->new;
    $name = $stringValidator->validateName($name);
	my $logger = get_logger();
	if(!defined($name))
	{
		$logger->info("validateName name is not defined!");
	}
	else
	{
		$logger->info("Name validated as: \"$name\"");
	}
	return $name;
}

sub redirectIfBadName
{
    my ($cgi, $formContentsHRef, $exitRedirectsHRef, $expectedFieldNamesHRef) = @ARG;
	my $logger = get_logger();
	$logger->info("redirectIfBadName");
    redirectIfBad($cgi, $expectedFieldNamesHRef->{'name'}, 
                $formContentsHRef,
                $exitRedirectsHRef,
                $expectedFieldNamesHRef);    
}


sub redirectIfBadEmail
{
    my ($cgi, $formContentsHRef, $exitRedirectsHRef, $expectedFieldNamesHRef) = @ARG;
    redirectIfBad($cgi, $expectedFieldNamesHRef->{'email'}, 
                $formContentsHRef,
                $exitRedirectsHRef,
                $expectedFieldNamesHRef);    
}


sub redirectIfBadSubject
{
    my ($cgi, $formContentsHRef, $exitRedirectsHRef, $expectedFieldNamesHRef) = @ARG;
    redirectIfBad($cgi, $expectedFieldNamesHRef->{'subject'}, 
                $formContentsHRef,
                $exitRedirectsHRef,
                $expectedFieldNamesHRef);    
}


sub redirectIfBadMessage
{
    my ($cgi, $formContentsHRef, $exitRedirectsHRef, $expectedFieldNamesHRef) = @ARG;
    redirectIfBad($cgi, $expectedFieldNamesHRef->{'message'}, 
                $formContentsHRef,
                $exitRedirectsHRef,
                $expectedFieldNamesHRef);    
}

sub redirectIfBad
{
    my($cgi, $fieldName, $formContentsHRef, $exitRedirectsHRef, $expectedFieldNamesHRef) = @ARG;  

    my $fieldValue = $formContentsHRef->{$fieldName};
    # name is bad for some reason so we need to draw the form
    # with any vald content and error boxes
    # is the name empty or illegal
	my $logger = get_logger();
    if(!defined($fieldValue))
    {
		$logger->info("Opening illegal page");
        open(ERRORPAGE, $exitRedirectsHRef->{"illegal_$fieldName"}) or $logger->logdie("Cannot open form HTML illegal $fieldName error file");
    }
    elsif($fieldValue eq "")
    {
		$logger->info("Opening missing page");
        open(ERRORPAGE, $exitRedirectsHRef->{"missing_$fieldName"}) or $logger->logdie("Cannot open form HTML missing $fieldName error file");
    }
    else
    {
		$logger->info("returing ok");
        return; # name is defined and is not a empty string 
    }
    local $INPUT_RECORD_SEPARATOR = undef;
	$logger->info("reading file");
    my $file = <ERRORPAGE>;
    close(ERRORPAGE);
	$logger->info("injecting elements");
    $file = injectFieldValuesIntoInputElements($file, $expectedFieldNamesHRef, $formContentsHRef);
    if($fieldName eq "message")
    {
        $file = injectErrorBoxAroundTextareaElement($file, $fieldName);
    }
    else
    {
        $file = injectErrorBoxAroundInputElement($file, $fieldName);
    }
	$logger->info("returning browser page");
    returnPageToBrowser($cgi, $file);
    $logger->info("exit here");
	exit(0);
}

sub injectFieldValuesIntoInputElements
{
    my($file, $expectedFieldNamesHRef, $formContentsHRef) = @ARG;
    $file = injectFieldValueIntoInputElement($file, $expectedFieldNamesHRef->{'name'}, $formContentsHRef->{'name'});
    $file = injectFieldValueIntoInputElement($file, $expectedFieldNamesHRef->{'email'}, $formContentsHRef->{'email'});
    $file = injectFieldValueIntoInputElement($file, $expectedFieldNamesHRef->{'subject'}, $formContentsHRef->{'subject'});
    $file = injectFieldValueIntoTextareaElement($file, $expectedFieldNamesHRef->{'message'}, $formContentsHRef->{'message'});
    return $file;
}


sub returnPageToBrowser
{
    my ($cgi, $file) = @ARG;
    print $cgi->header(); #need to pass cgi....
    print $file;
	my $header = $cgi->header();
	my $logger = get_logger();
	$logger->info("Redirect to: $header");
	$logger->info("page source:\n $file");
}


sub injectFieldValueIntoInputElement
{
    my ($file, $field, $value) = @ARG;
    if(defined($value))
    {
        $file =~ s{<input\ name='$field'}[<input\ name='$field'\ value='$value']gix;
    }
    return $file;
}


sub injectFieldValueIntoTextareaElement
{
    my ($file, $field, $value) = @ARG;
    if(defined($value))
    {
        $file =~ s{<textarea\ name='$field'.?>}[$MATCH $value]gix;
    }
    return $file;
}


sub injectErrorBoxAroundInputElement
{
    my ($file, $field) = @ARG;
    $file =~ s{<input\ name='$field'.*>}[<div class='error'>$MATCH</div>]gix;
    return $file;
}

sub injectErrorBoxAroundTextareaElement
{
    my ($file, $field) = @ARG;
    $file =~ s{<textarea\ name='$field'.*>}[<div class='error'>$MATCH</div>]gix;
    return $file;
}


sub validateEmail
{
    my ($email) = @ARG;
    $email = trimWhiteSpace($email);
    if($email eq "")
    {
        return $email;
    }
    my $emailvalidator = Validation::EmailAddress->new;
    $email =  $emailvalidator->validateEmail($email);
    return $email;
}

sub validateSubject
{
    my ($subject) = @ARG;
    my $stringValidator = Validation::ContextSpecificStrings->new;
    $subject = $stringValidator->validateSubject($subject);
    return $subject;
}


sub validateMessage
{
    my ($message) = @ARG;
    my $stringValidator = Validation::ContextSpecificStrings->new;
    $message = $stringValidator->validateMessage($message);
    return $message;
}




sub trimWhiteSpace
{
    my($string) = @ARG;
    my $stringValidator = Validation::ContextSpecificStrings->new;
    $string = $stringValidator->stripLeadingAndTrailingWhiteSpace($string);
    return $string;
}



# This is just enough to send an US-ASCII encoded email to
# the address contactform@kualwe.com.
# It doesn't suport MIME encodedmessages (so not multi0lingual)
# and it doesn't check the return value of the sendmail call
sub sendEmailOrRedirect
{
    my ($formContentsHRef, $success_page, $error_page) = @ARG;
    my $exit = sendEmail($formContentsHRef);
	my $logger = get_logger();
    if($exit != 0)
    {
        $logger->warn("The call to sendmail failed!!! Errno: $exit");
        # we should redirect to an error page for the user...
        redirectAndExit($cgi, $error_page);
    }
    redirectAndExit($cgi, $success_page);        
}

sub sendEmail
{
    my ($formContentsHRef) = @ARG;
	my $logger = get_logger();
    open(SENDMAIL, "|/usr/sbin/sendmail -i -t") or
        $logger->logdie("Can't fork sendmail:$ERRNO\n");
    print SENDMAIL <<"EOF";
From: Kulawe Contact Form <do-not-reply\@kulawe.com>
To: $formContentsHRef->{'name'} <$formContentsHRef->{'email'}>
Bcc: contactform\@kulawe.com
Reply-To: do-not-reply\@kulawe.com
Subject: Kulawe Contact Form Message: "$formContentsHRef->{'subject'}"

Dear $formContentsHRef->{'name'},

Thank you for sending a message to the team at Kulawe. A member
of the team will be intouch with you over the next few days to
discuss your question in more detail.

This email address is not monitored so, please do not reply to this email.

Thank you

The team at Kulawe.



The following message has been received by the Kulawe 'Contact Us' website form:
From: $formContentsHRef->{'name'} <$formContentsHRef->{'email'}>
Subject: $formContentsHRef->{'subject'}
Message: $formContentsHRef->{'message'}
    
Technical Information
---------------------

User-Agent: $ENV{'HTTP_USER_AGENT'}
Sender IP Address: $ENV{'REMOTE_ADDR'}

EOF
    close(SENDMAIL);
    my $exit = $? >> 8;
    return $exit;
}

sub redirectAndExit
{
    my($cgi, $page) = @ARG;
	my $logger = get_logger();
    $logger->warn("redirecting to: $page");
    print $cgi->redirect($page);
    $logger->warn("Exiting now...");    
    exit(0);
}


