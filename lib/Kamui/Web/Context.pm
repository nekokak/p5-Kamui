package Kamui::Web::Context;
use Kamui;
use URI;
use Encode;
use Carp ();

sub load_plugins {
    my ($class, $plugins) = @_;

    for my $plugin (@{$plugins}) {
        my $pkg = $plugin;
        $pkg = _plugin_name($pkg);
        $class->load_class($pkg);

        my $register_methods = $pkg->register_method;
        while (my($method, $initialize_code) = each %{ $register_methods }) {

            my $code = sub {
                my $self = shift;
                $self->{_plugin}->{$method} ||= $initialize_code->($self);
            };

            no strict 'refs';
            *{"$class\::$method"} = $code;
        }
    }
}

sub new {
    my $class = shift;
    bless {
        filters => [],
        @_
    }, $class;
}

sub _plugin_name {
    my $pkg = shift;
    $pkg = 'Kamui::Plugin::'.$pkg unless $pkg =~ s/^\+//;
    return $pkg;
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
    my $res = $self->view->render($self);

    $self->output_filter($res);
}

sub output_filter {
    my ($self, $res) = @_;

    for my $filter (@{$self->{filters}}) {
        $res = $filter->($self, $res);
    }

    return $res;
}

sub add_filter {
    my($self, $code) = @_;

    unless (ref($code) eq 'CODE') {
        Carp::croak("add_filter() needs coderef");
    }
    push @{$self->{filters}}, $code;
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

