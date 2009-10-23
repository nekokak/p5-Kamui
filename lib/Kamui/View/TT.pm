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
            context => $context,
        },
        \my $output
    ) or die $@;

    my $res = $context->res;
    $res->status('200');
    $res->body(Encode::encode('utf8',$output));
    $res->headers([ 'Content-Type' => 'text/html' ]);
    $res;
}

1;

