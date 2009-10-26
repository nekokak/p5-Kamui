package Kamui::Plugin::Encode;
use Kamui;
use base 'Kamui::Plugin';
use Encode;
use Data::Visitor::Encode;

sub register_method {
    +{
        prepare_encoding => sub {
            my $c = shift;
            $c->req->parameters(
                Data::Visitor::Encode->decode( 'utf8', $c->req->parameters )
            );
        },
        finalize_encoding => sub {
            my $c = shift;
            my $res = $c->res;
            my $body = $res->body;
            $res->body(Encode::encode('utf8',$body));
        },
    },
};

1;

