package Kamui::View::JSON;
use Kamui;
use base 'Kamui::View';
use JSON::XS;

sub render {
    my ($class, $context) = @_;

    my $data = $context->stash->{$context->conf->{view}->{json}->{stash_key} || 'json'};
    my $cb_param = $context->conf->{view}->{json}->{callback_param} || 'callback';
    my $cb = $cb_param ? _validate_callback_param($context->req->param($cb_param)||'') : undef;

    my $json = encode_json($data);

    my $content_type;
    if (($context->req->user_agent || '') =~ /Opera/) {
        $content_type = 'application/x-javascript; charset=utf-8';
    } else {
        $content_type = 'application/json; charset=utf-8';
    }

    my $output;
    ## add UTF-8 BOM if the client is Safari ### XXXX
    if (($context->req->user_agent || '') =~ m/Safari/) {
        $output = "\xEF\xBB\xBF";
    }

    $output .= "$cb(" if $cb;
    $output .= $json;
    $output .= ");"   if $cb;

    my $res = $context->res;
    $res->status('200');
    $res->body($output);
    $res->headers([ 'Content-Type' => $content_type ]);
    $res;
}

sub _validate_callback_param {                                                                                                                              
    my $param = shift;
    $param =~ /^[a-zA-Z0-9\.\_\[\]]+$/ ? $param : undef;
}   

1;

