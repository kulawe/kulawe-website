#!/usr/bin/perl -w
# Create a user agent object
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

# Create a request
my $req = HTTP::Request->new(POST => 'http://www.kulawe.com/cgi-bin/contact-us.pl');
$req->content_type('application/x-www-form-urlencoded');
$req->content('=Value-With-No-Key');

# Pass request to the user agent and get a response back
my $res = $ua->request($req);

# Check the outcome of the response
if ($res->is_success) {
    print $res->content;
}
else {
    print $res->status_line, "\n";
    print $res->content, "\n";
}
