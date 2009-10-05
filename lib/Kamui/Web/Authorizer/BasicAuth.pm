package Kamui::Web::Authorizer::BasicAuth;
use Kamui;
use base qw/Kamui::Web::Authorizer Class::Data::Inheritable/;
use MIME::Base64;

__PACKAGE__->mk_classdata(realm => 'Authorization Required');

sub basic_auth {
    my ($class, $context) = @_;

    my $auth_header = $context->req->header('Authorization') || '';
    if ($auth_header =~ /^Basic (.+)$/) {
        my ($user, $pass) = split q{:}, MIME::Base64::decode_base64($1);
        if (defined $user and defined $pass) {
            return ($user, $pass);
        }
    }
    return $class->show_error_page($context);
}

sub show_error_page {
    my ($class, $context) = @_;
    my $realm = $class->realm;
    [
        401,
        [
            "Content-Type"     => "text/plain",
            "Content-Length"   => 21,
            "WWW-Authenticate" => qq{Basic realm="$realm"}
        ],
        ["not authorized"]
    ];
}

1;

