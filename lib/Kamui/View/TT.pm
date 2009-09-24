package Kamui::View::TT;
use Kamui;
use base 'Kamui::View';
use Template;
use File::Spec;
use Template::Stash::EscapeHTML;
use HTML::Entities;
use String::CamelCase qw/decamelize/;

sub render {
    my ($class, $context) = @_;

    my $template = $context->load_template || $class->guess_filename($context);

    my $tt = Template->new(
        ABSOLUTE     => 1,
        RELATIVE     => 1,
        ENCODING     => 'utf-8',
        STASH        => Template::Stash::EscapeHTML->new,
        FILTERS      => +{
            html_unescape => sub { HTML::Entities::decode_entities(shift) },
        },
        COMPILE_DIR  => '/tmp/' . $ENV{USER} . "/",
        INCLUDE_PATH => [ '.', File::Spec->catfile($context->conf->{tmpl}->{path}) ],
        %{ $context->conf->{tmpl}->{options} || {} },
    );
    $tt->process(
        $template,
        {
            %{ $context->stash },
            context => $context,
        },
        \my $output
    ) or die $@;

    $output;
}

sub guess_filename {
    my ($class, $context) = @_;
    (my $controller = $context->dispatch_rule->{controller}) =~ s/.+Controller::(.+)$/$1/i;
    sprintf('%s/%s.html', decamelize($controller), $context->dispatch_rule->{action} );
}

1;

