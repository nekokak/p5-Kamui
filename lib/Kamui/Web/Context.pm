package Kamui::Web::Context;
use Kamui;
use Encode;
use Carp ();
use HTML::FillInForm::Lite;
use FormValidator::Lite;
use String::CamelCase qw/camelize decamelize/;

sub _plugin_name {
    my $pkg = shift;
    $pkg = 'Kamui::Plugin::'.$pkg unless $pkg =~ s/^\+//;
    return $pkg;
}

sub load_plugins {
    my ($class, $plugins) = @_;

    for my $plugin (@{$plugins}) {
        my $pkg = _plugin_name($plugin);
        $class->load_class($pkg);

        my $register_methods = $pkg->register_method;
        while (my($method, $initialize_code) = each %{ $register_methods }) {

            my $code = sub {
                my $context = shift;
                $context->{_plugin}->{$method} ||= $initialize_code->($context);
            };

            no strict 'refs';
            *{"$class\::$method"} = $code;
        }
    }
}

sub new {
    my $class = shift;
    bless {
        app          => undef, # set application class.
        _filters     => [],
        _fillin_fdat => undef,
        @_
    }, $class;
}

sub app { $_[0]->{app} }
sub req {
    my $self = shift;
    $self->{req} ||= do {
        $self->app->load_class('Kamui::Web::Request');
        Kamui::Web::Request->new($self->{env});
    };
}

sub dispatch_rule { $_[0]->{dispatch_rule} }

sub fillin_fdat {
    my ($self, $val) = @_;
    $self->{fillin_fdat} = $val if $val;
    $self->{fillin_fdat};
}

sub view {
    my ($self, $view) = @_;

    if ($view) {
        $self->{view} = 'Kamui::View::'.$view;
    } else {
        $self->{view};
    }
}

sub load_template : lvalue { $_[0]->{load_template} }
sub guess_filename {
    my $self = shift;

    (my $controller = $self->dispatch_rule->{controller}) =~ s/.+Controller::(.+)$/decamelize($1)/ie;
    $controller = join '/', split '::', $controller;
    sprintf('%s/%s.html', decamelize($controller), $self->dispatch_rule->{action} );
}

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

    $res = $self->fillin_form($res);
    $res = $self->output_filter($res);
    $res;
}

sub fillin_form {
    my ($self, $res) = @_;

    my $fdat = $self->fillin_fdat;
    return $res unless $fdat;

    $res->[2]->[0] = HTML::FillInForm::Lite->fill(\$res->[2]->[0], $fdat);
    $res;
}

sub output_filter {
    my ($self, $res) = @_;

    for my $filter (@{$self->{_filters}}) {
        $res = $filter->($self, $res);
    }

    $res;
}

sub add_filter {
    my($self, $code) = @_;

    unless (ref($code) eq 'CODE') {
        Carp::croak("add_filter() needs coderef");
    }
    push @{$self->{_filters}}, $code;
}

sub validator {
    my ($self, $valid_class_s) = @_;

    my $valid_class = join '::', $self->app->base_name, 'Web', 'Validator', camelize($valid_class_s);
    $self->load_class($valid_class);

    my $validator = $valid_class->new(
        engine  => FormValidator::Lite->new($self->req),
        context => $self,
    );

    $validator->{engine}->set_message_data($self->conf->{'validator_message'});

    return $validator;
}

sub is_finished { $_[0]->{is_finished} }
sub redirect {
    my ($self, $path, $params) = @_;

    $self->app->load_class('URI');

    my $uri = URI->new($path);
    $params ||= +{};
    $uri->query_form(%{$params});

    $self->{is_finished} = 1;
    [ 302, [ 'Location' => $uri->as_string ], [''] ];
}

sub uri_with {
    my ($self, @path) = @_;

    $self->app->load_class('URI::WithBase');

    my $params = ref $path[-1] eq 'HASH' ? pop @path : {};

    (my $path = join '/', @path) =~ s!/{2,}!/!g;
    $path =~ s!^/+!!;
    my $uri = URI::WithBase->new($path, $self->req->base);
    $uri->query_form($params);

    $uri->abs;
}

sub finalize {
    my ($self, $response) = @_;

    $self->finalize_plugins($response);
}

sub finalize_plugins {
    my ($self, $response) = @_;

    for my $plugin (keys %{$self->{_plugin}}) {
        if ($self->$plugin->can('finalize')){
            $self->$plugin->finalize($response);
        }
    }
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

