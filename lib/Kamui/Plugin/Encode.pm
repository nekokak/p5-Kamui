package Kamui::Plugin::Encode;
use Kamui;
use base 'Kamui::Plugin';
use Encode ();

sub register_method {
    +{
        prepare_encoding => sub {
            my $c = shift;

            my $params = $c->req->parameters;
            my $decoded_params = {};
            while (my($k, $v) = each %$params) {
                $decoded_params->{Encode::decode_utf8($k)} = ref $v eq 'ARRAY'
                    ? [ map Encode::decode_utf8($_), @$v ] : Encode::decode_utf8($v);
            }
            $c->req->parameters($params);
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

