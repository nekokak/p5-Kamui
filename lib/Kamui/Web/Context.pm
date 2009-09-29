package Kamui::Web::Context;
use Kamui;
use URI;
use Encode;

sub new {
    my $class = shift;
    bless {
        @_
    }, $class;
}

sub req { $_[0]->{req} }
sub dispatch_rule { $_[0]->{dispatch_rule} }

sub view {
    my ($self, $view) = @_;

    if ($view) {
        $self->{view} = 'Kamui::View::'.$view;
    } else {
        $self->{view};
    }
}

sub load_template : lvalue { $_[0]->{load_template} }
sub stash : lvalue {
    my $self = shift;
    $self->{_stash} ||= +{};
}
sub conf { $_[0]->{conf} }

sub render {
    my $self = shift;

    $self->load_class($self->view);
    $self->view->render($self);
}

sub is_finished { $_[0]->{is_finished} }
sub redirect {
    my ($self, $path, $params) = @_;

    my $uri = URI->new($path);
    $params ||= +{};
    $uri->query_form(%{$params});

    $self->{is_finished} = 1;
    [ 302, [ 'Location' => $uri->as_string ], [''] ];
}

sub handle_404 {
    [
        404, [ "Content-Type" => "text/plain", "Content-Length" => 13 ],
        ["404 Not Found"]
    ];
}

sub handle_500 {
    [
        500, [ "Content-Type" => "text/plain", "Content-Length" => 21 ],
        ["Internal Server Error"]
    ];
}

1;

