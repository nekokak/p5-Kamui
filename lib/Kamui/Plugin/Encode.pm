package Kamui::Plugin::Encode;
use Kamui;
use base 'Kamui::Plugin';
use Encode ();
use Hash::MultiValue;

sub register_method {
    +{
        prepare_encoding => sub {
            my $c = shift;

            $c->req->env->{'plack.request.query'} ||= _decode_multivalue( Hash::MultiValue->new($c->req->uri->query_form) );
            unless ($c->req->env->{'plack.request.body'}) {
                $c->req->_parse_request_body;
                $c->req->env->{'plack.request.body'} = _decode_multivalue( $c->req->env->{'plack.request.body'} );
            }
        },
        finalize_encoding => sub {
            my $c = shift;
            my $res = $c->res;
            my $body = $res->body;
            $res->body(Encode::encode('utf8',$body)) unless $c->view eq 'Kamui::View::JSON';
        },
    },
};

sub _decode_multivalue {
    my $hash = shift;

    my $params = $hash->mixed;
    my $decoded_params = {};
    while (my($k, $v) = each %$params) {
        $decoded_params->{Encode::decode_utf8($k)} = ref $v eq 'ARRAY'
            ? [ map Encode::decode_utf8($_), @$v ] : Encode::decode_utf8($v);
    }
    return Hash::MultiValue->from_mixed(%$decoded_params);
}

1;

