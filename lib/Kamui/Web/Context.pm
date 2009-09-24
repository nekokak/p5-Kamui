package Kamui::Web::Context;
use Kamui;
use URI;

sub new {
    my $class = shift;
    bless {
        view => 'Kamui::View::TT',
        @_
    }, $class;
}

sub req { $_[0]->{req} }
sub app { $_[0]->{app} }
sub dispatch_rule { $_[0]->{dispatch_rule} }
sub view : lvalue { $_[0]->{view} }
sub load_template : lvalue { $_[0]->{load_template} }
sub stash : lvalue {
    my $self = shift;
    $self->{_stash} ||= +{};
}
sub conf { $_[0]->{conf} }

sub render {
    my $self = shift;

    $self->load_class($self->view);
    my $out = $self->view->render($self);

    return [ 200, [ 'Content-Type' => 'text/html' ], [$out] ];
}

sub is_redirect { $_[0]->{is_redirect} }
sub redirect {
    my ($self, $path, $params) = @_;

    my $uri = URI->new($path);
    $params ||= +{};
    $uri->query_form(%{$params});

    $self->{is_redirect} = 1;
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

