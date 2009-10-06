package Kamui::View::TT;
use Kamui;
use base 'Kamui::View';
use Template;
use File::Spec;
use Template::Stash::EscapeHTML;
use String::CamelCase qw/decamelize/;
use Encode;

sub render {
    my ($class, $context) = @_;

    my $template = $context->load_template || $class->guess_filename($context);

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

    return [ 200, [ 'Content-Type' => 'text/html' ], [Encode::encode('utf8',$output)] ];
}

sub guess_filename {
    my ($class, $context) = @_;
    (my $controller = $context->dispatch_rule->{controller}) =~ s/.+Controller::(.+)$/decamelize($1)/ie;
    $controller = join '/', split '::', $controller;
    sprintf('%s/%s.html', decamelize($controller), $context->dispatch_rule->{action} );
}

1;

