package Kamui::Plugin::Mobile::Agent;
use Kamui;
use base 'Kamui::Plugin';
use HTTP::MobileAgent;
use HTTP::MobileAgent::Plugin::Charset;

sub register_method {
    +{
        mobile => sub {
            my $c = shift;
            HTTP::MobileAgent->new($c->req->headers);
        },
    };
}

1;

