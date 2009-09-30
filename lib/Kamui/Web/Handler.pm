package Kamui::Web::Handler;
use Kamui;
use Kamui::Web::Context;
use Kamui::Web::Controller;
use Plack::Request;
use UNIVERSAL::require;

sub import {
    my $caller = caller;

    my $pkg = caller(0);
    for my $meth ( qw/new psgi_handler use_container dispatcher view/ ) {
        no strict 'refs';
        *{"$pkg\::$meth"} = \&$meth;
    }

    goto &Kamui::import;
}

sub new {
    my $class = shift;
    bless {}, $class;
}

my $dispatcher;
sub dispatcher ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die $@;
    $dispatcher = $pkg;
}

my $view;
sub view ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die;
    $view = $pkg;
}

sub use_container($) { ## no critic.
    my $container = shift;
    $container->use or die $@;
}

sub psgi_handler {
    my $self = shift;

    sub {
        my $env = shift;

        my $req  = Plack::Request->new($env);

        $dispatcher ||= do {
            my $dispatch_class = join '::', $self->base_name, 'Web', 'Dispatcher';
            dispatcher($dispatch_class);
        };

        $dispatcher->determine($req);
        my $rule = $dispatcher->determine($req);

        my $context = Kamui::Web::Context->new(
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

