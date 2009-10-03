package Kamui::Plugin::Session;
use Kamui;
use base 'Kamui::Plugin';
use HTTP::Session;

sub register_method {
    +{
        session => sub {
            my $c = shift;

            HTTP::Session->new(
                request => $c->req,
                %{$c->conf->{plugins}->{session}}
            );
        },
    };
}

1;

