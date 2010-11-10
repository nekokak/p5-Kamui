package Kamui::Web::Handler;
use Kamui;
use Kamui::Web::Context;
use Kamui::Web::Controller;
use UNIVERSAL::require;
use Data::Dumper;

sub import {
    my $caller = caller;

    my @methods = qw/
        new setup handler dispatcher dispatch context_class
        use_container use_context use_dispatcher use_view use_plugins
    /;

    for my $meth ( @methods ) {
        no strict 'refs'; ## no critic.
        *{"$caller\::$meth"} = \&$meth;
    }

    my $_attribute = +{};
    no strict 'refs'; ## no critic.
    *{"$caller\::attribute"} = sub { $_attribute };

    goto &Kamui::import;
}

sub dispatcher { $_[0]->attribute->{dispatcher} }
sub use_dispatcher ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die $@;
    caller(0)->attribute->{dispatcher} = $pkg;
}

sub use_view ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die $@;
    caller(0)->attribute->{view} = $pkg;
}

sub use_container($) { ## no critic.
    my $container = shift;
    $container->use or die $@;
}

sub context_class { $_[0]->attribute->{context_class} }
sub use_context ($) { ## no critic.
    my $pkg = shift;
    $pkg->use or die $@;
    caller(0)->attribute->{context_class} = $pkg;
}

sub use_plugins ($) { ## no critic.
    my $pkgs = shift;
    caller(0)->attribute->{plugins} = $pkgs;
}

sub new {
    my $class = shift;

    my $context_class = $class->context_class || do {
        'Kamui::Web::Context'->use or die $@;
        $class->attribute->{context_class} = 'Kamui::Web::Context';
    };
    $context_class->load_plugins($class->attribute->{plugins});

    $class->dispatcher or do {
        my $dispatch_class = join '::', $class->base_name, 'Web', 'Dispatcher';
        $class->attribute->{dispatcher} = $dispatch_class;
    };

    bless {}, $class;
}


sub setup { warn 'setup method is deprecated'; shift }

sub handler {
    my $self = shift;

    sub {
        my $env = shift;

        $env->{PATH_INFO} ||= '/';

        my $context = $self->context_class->new(
            env           => $env,
            dispatch_rule => +{},
            view          => $self->attribute->{view} || 'Kamui::View::TT',
            conf          => container('conf'),
            app           => $self,
        );
        $context->initialize();

        my $rule = $self->dispatcher->determine($context);
        $context->dispatch_rule($rule);

        my $response = $self->dispatch($context);
        $context->finalize($response);

        $response->finalize;
    };
}

sub dispatch {
    my ($self, $context) = @_;

    my $controller = $context->dispatch_rule->{controller}||'';
    ($controller && $controller->use) or do {
        warn "[404] controller : $controller $@ (path: $context->{env}->{PATH_INFO})";
        return $context->handle_404;
    };

    my $action = $context->dispatch_rule->{action} or do {
        warn "[500] controller : $controller, action : $context->dispatch_rule->{action} $@ (path: $context->{env}->{PATH_INFO})";
        return $context->handle_404;
    };

    my $method = 'do_'.$action;
    if ($context->dispatch_rule->{is_static}) {
        no strict 'refs'; ## no critic.
        *{"${controller}::${method}"} = sub { "empty" };
    }

    if (my $dispatch_code = $controller->can($method)) {

        my $res;
        eval {

            if (my $not_authorized = $controller->authorize($dispatch_code, $context)) {
                $res = $not_authorized;
            } else {
                $controller->call_trigger('before_dispatch', $context, $context->dispatch_rule->{args});
                $res = $controller->$method($context, $context->dispatch_rule->{args});
                $controller->call_trigger('after_dispatch', $context, $context->dispatch_rule->{args});
            }
        };
        if ( $context->is_detach($@) ) {
            return $context->res;
        } elsif($@) {
            warn $@;
            return $context->handle_500;
        }
        return $res if $context->is_finished;
        return $context->render;
    } else {
        warn q{can not find dispatch method.};
        return $context->handle_404;
    }
}

1;

