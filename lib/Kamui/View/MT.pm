package Kamui::View::MT;
use Kamui;
use base 'Kamui::View';
use Text::MicroTemplate::Extended;
use File::Spec;
use Encode;
use URI::Escape;
use HTML::Entities;

sub render {
    my ($class, $context) = @_;

    my $c     = sub { $context };
    my $stash = sub { $context->stash };
    my $template = $context->load_template || $context->guess_filename;

    # TODO: set macro
    my $mt = Text::MicroTemplate::Extended->new(
        package_name  => $context->base_name . '::_MT',
        include_path  => [ '.', File::Spec->catfile($context->conf->{view}->{mt}->{path}) ],
        extension     => '',
        use_cache     => 1,
        open_layer    => ':utf8',
        macro         => {
            raw_string => sub($) { Text::MicroTemplate::EncodedString->new($_[0]) },
            uri => sub($) {
                Encode::is_utf8( $_[0] )
                    ? URI::Escape::uri_escape_utf8($_[0])
                    : URI::Escape::uri_escape($_[0]);
            },
            html_unescape => sub($) {
                HTML::Entities::decode_entities($_[0]);
            },
        },
        template_args => {
            stash => $stash,
            s     => $stash,
            c     => $c,
        },
        %{ $context->conf->{view}->{mt}->{options} || {} },
    );
    my $output = $mt->render($template)->as_string;

    $context->res->status('200');
    $context->res->body($output);
    $context->res->headers([ 'Content-Type' => 'text/html' ]);
    $context->res;
}

1;

