package Kamui::Web::Context;
use Kamui;
use Carp ();
use HTML::FillInForm::Lite;
use String::CamelCase qw/camelize decamelize/;

sub _plugin_name {
    my $pkg = shift;
    $pkg = 'Kamui::Plugin::'.$pkg unless $pkg =~ s/^\+//;
    return $pkg;
}

my @initialize_plugins;
my @finalize_plugins;
sub load_plugins {
    my ($class, $plugins) = @_;
    $class = ref $class || $class;

    for my $plugin (@{$plugins}) {
        my $pkg = _plugin_name($plugin);
        $class->load_class($pkg);

        my $register_methods = $pkg->register_method;
        while (my($method, $initialize_code) = each %{ $register_methods }) {

            if ($pkg->do_initialize) {
                push @initialize_plugins, $method;
            }
            if ($pkg->do_finalize) {
                push @finalize_plugins, $method;
            }
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
sub res {
    my $self = shift;
    $self->{res} ||= do {
        $self->app->load_class('Kamui::Web::Response');
        Kamui::Web::Response->new;
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
    my $res = $self->view->render($self);

    $res = $self->fillin_form($res);
    $res = $self->output_filter($res);
    $res;
}

sub fillin_form {
    my ($self, $res) = @_;

    my $fdat = $self->fillin_fdat;
    return $res unless $fdat;

    my $body = $res->body;
    $res->body(
        HTML::FillInForm::Lite->fill(\$body, $fdat)
    );
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

sub is_finished { $_[0]->{is_finished} }
sub redirect {
    my ($self, $path, $params) = @_;

    $self->app->load_class('URI');

    my $uri = URI->new($path);
    $params ||= +{};
    $uri->query_form(%{$params});

    $self->{is_finished} = 1;
    $self->res->content_type("text/html");
    $self->res->redirect($uri->as_string);
    $self->detach;
}

our $DETACH = 'KAMUI_DETACH';
sub detach { die $DETACH }
sub is_detach {
    my ($self, $detach) = @_;
    return unless $detach;
    $detach =~ /^${DETACH} at/;
}

sub initialize {
    my $self = shift;

    unless ( $self->can('prepare_encoding') ) {
        $self->load_plugins([qw/Encode/]);
    }

    $self->prepare_encoding();
    $self->initialize_plugins;
}

sub initialize_plugins {
    my $self = shift;

    for my $plugin (@initialize_plugins) {
        $self->$plugin->initialize;
    }
}

sub finalize {
    my ($self, $response) = @_;

    $self->finalize_plugins($response);
    $self->finalize_encoding;
}

sub finalize_plugins {
    my ($self, $response) = @_;

    for my $plugin (@finalize_plugins) {
        $self->$plugin->finalize($response);
    }
}

sub uri_with {
    my($self, $args) = @_;
    
    Carp::carp( 'No arguments passed to uri_with()' ) unless $args;

    for my $value (values %{ $args }) {
        next unless defined $value;
        for ( ref $value eq 'ARRAY' ? @{ $value } : $value ) {
            $_ = "$_";
            utf8::encode( $_ );
        }
    };
    
    my $uri = $self->req->uri->clone;
    $uri->query_form( {
        %{ $uri->query_form_hash },
        %{ $args },
    } );
    return $uri;
}


sub handle_404 {
    my $self = shift;

    my $res = $self->res;
    $res->status('404');
    $res->headers([ 'Content-Type' => 'text/plain', 'Content-Length' => 13 ]);
    $res->body('404 Not Found');

    $res;
}

sub handle_500 {
    my $self = shift;

    my $res = $self->res;
    $res->status('500');
    $res->headers([ 'Content-Type' => 'text/plain', 'Content-Length' => 21 ]);
    $res->body('Internal Server Error');

    $res;
}

1;

