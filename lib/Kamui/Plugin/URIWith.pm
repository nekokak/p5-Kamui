package Kamui::Plugin::URIWith;
use Kamui;
use base 'Kamui::Plugin';
use Carp;
use URI;
use URI::QueryParam;

sub register_method {
    +{
        uri_with => sub {
            my $c = shift;
            sub {
                my $args = shift;
                carp('No arguments passed to uri_with()') unless $args;

                my $uri = URI->new( $c->req->uri );
                $uri->query_form( { %{ $uri->query_form_hash }, %$args } );
                return $uri;
            };
        },
    };
}

1;

