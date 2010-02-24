package Kamui::Plugin::Mobile::Encode;
use Kamui;
use base 'Kamui::Plugin';
use Encode ();
use Encode::JP::Mobile;
use Hash::MultiValue;

sub register_method {
    +{
        prepare_encoding => sub {
            my $c = shift;

            $c->req->env->{'plack.request.query'} ||= _decode_multivalue( Hash::MultiValue->new($c->req->uri->query_form), $c->mobile->encoding );
            unless ($c->req->env->{'plack.request.body'}) {
                $c->req->_parse_request_body;
                $c->req->env->{'plack.request.body'} = _decode_multivalue( $c->req->env->{'plack.request.body'}, $c->mobile->encoding );
            }
        },

        finalize_encoding => sub {
            my $c = shift;
            my $res = $c->res;

            if ( $res && $res->status == 200
                && $res->content_type =~ /html/
                && $res->body )
            {
                my $body = $res->body;
                $res->body( Encode::encode( $c->mobile->encoding, $body ) );

                my $content_type = $res->content_type || 'text/html';
                if ($content_type =~ m!^text/!) {
                    my $charset = $c->mobile->can_display_utf8 ? 'UTF-8' : 'Shift_JIS';
                    unless ($content_type =~ s/charset\s*=\s*[^\s]*;?/charset=$charset/ ) {
                        $content_type .= '; ' unless $content_type =~ /;\s*$/;
                        $content_type .= "charset=$charset";
                    }
                    if ( $content_type =~ m!^text/html!) {
                        if ( $c->mobile->is_docomo && $c->mobile->xhtml_compliant ) {
                            $content_type =~ s!text/html!application/xhtml+xml!;
                        }
                    }
                    $res->content_type( $content_type );
                }
            }
        },
    };
}

sub _decode_multivalue {
    my ($hash, $encoding) = @_;

    my $params = $hash->mixed;
    my $decoded_params = {};
    while (my($k, $v) = each %$params) {
        $decoded_params->{Encode::decode($encoding, $k)} = ref $v eq 'ARRAY'
            ? [ map Encode::decode($encoding, $_), @$v ] : Encode::decode($encoding, $v);
    }
    return Hash::MultiValue->from_mixed(%$decoded_params);
}

1;

