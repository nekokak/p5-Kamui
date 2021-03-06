package Kamui::View::TT;
use Kamui;
use base 'Kamui::View';
use Template;
use File::Spec;
use Template::Stash::EscapeHTML;
use Encode;

sub render {
    my ($class, $context) = @_;

    my $template = $context->load_template || $context->guess_filename;

    my $tt = Template->new(
        ABSOLUTE     => 1,
        RELATIVE     => 1,
        ENCODING     => 'utf-8',
        STASH        => Template::Stash::EscapeHTML->new,
        FILTERS      => $context->conf->{view}->{tt}->{filters},
        COMPILE_DIR  => '/tmp/' . $ENV{USER} . "/",
        INCLUDE_PATH => [ '.', File::Spec->catfile($context->conf->{view}->{tt}->{path}) ],
        %{ $context->conf->{view}->{tt}->{options} || {} },
    );
    $tt->process(
        $template,
        {
            %{ $context->stash },
            c => $context,
        },
        \my $output
    ) or die "error: $@";

    $context->res->status('200');
    $context->res->body($output);
    $context->res->headers([ 'Content-Type' => 'text/html' ]);
    $context->res;
}

1;

