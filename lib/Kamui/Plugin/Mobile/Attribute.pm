package Kamui::Plugin::Mobile::Attribute;
use Kamui;
use base 'Kamui::Plugin';
use HTTP::MobileAttribute plugins => [qw/Core IS Encoding/];

sub register_method {
    +{
        mobile => sub {
            my $c = shift;
            HTTP::MobileAttribute->new($c->req->headers);
        },
    };
}

1;

