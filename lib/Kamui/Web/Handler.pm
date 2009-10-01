package Kamui::Web::Handler;
use Kamui;
use Kamui::Web::Context;
use Kamui::Web::Controller;
use Kamui::Web::Request;
use UNIVERSAL::require;

sub import {
    my $caller = caller;

    my $pkg = caller(0);
    my @methods = qw/
        new setup handler dispatcher
        use_container use_context use_dispatcher use_view use_plugins
    /;
    for my $meth ( @methods ) {
        no strict 'refs';
        *{"$pkg\::$meth"} = \&$meth;
    }

    goto &Kamui::import;
}

my $dispatcher;
sub dispatcher { $dispatcher }
sub use_dispatcher ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die $@;
    $dispatcher = $pkg;
}

my $view;
sub use_view ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die;
    $view = $pkg;
}

sub use_container($) { ## no critic.
    my $container = shift;
    $container->use or die $@;
}

my $context_class;
sub use_context ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die $@;
    $context_class = $pkg;
}

my $plugins = [];
sub use_plugins ($) { ## no critic.
    my $pkgs = shift;
    $plugins = $pkgs;
}

sub new {
    my $class = shift;

    $context_class ||= 'Kamui::Web::Context';
    $context_class->load_plugins($plugins);

    bless {}, $class;
}


sub setup {
    my $self = shift;

    $dispatcher ||= do {
        my $dispatch_class = join '::', $self->base_name, 'Web', 'Dispatcher';
        dispatcher($dispatch_class);
    };

    $self;
}

sub handler {
    my $self = shift;

    sub {
        my $env = shift;

        my $req  = Kamui::Web::Request->new($env);

        my $rule = $self->dispatcher->determine($req);

        my $context = $context_class->new(
            req           => $req,
            dispatch_rule => $rule,
            view          => $view || 'Kamui::View::TT',
            conf          => container('conf'),
        );

        return dispatch($context);
    };
}

sub dispatch {
    my $context = shift;

    my $controller = $context->dispatch_rule->{controller};
    $controller->use or do {
        warn $@;
        return $context->handle_404;
    };
    my $action = $context->dispatch_rule->{action} or do {
        warn $@;
        return $context->handle_404;
    };

    my $method = 'dispatch_'.$action;
    if ($controller->can($method)) {
        my $code;
        eval {
            $controller->call_trigger('before_dispatch', $context);
            $code = $controller->$method($context, $context->dispatch_rule->{args});
            $controller->call_trigger('after_dispatch', $context);
        };
        if ($@) {
            warn $@;
            return $context->handle_500;
        }
        return $code if $context->is_finished;
        return $context->render;
    } else {
        return $context->handle_404;
    }
}

1;

