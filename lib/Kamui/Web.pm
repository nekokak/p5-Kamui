package Kamui::Web;
use Kamui;

sub dispatcher { die 'this method is abstract: dispatch'  }
sub view       { die 'this method is abstract: view'      }
sub context    { die 'this method is abstract: context'   }
sub container  { die 'this method is abstract: container' }
sub plugins    { [] }

sub new {
    my $class = shift;

    $class->context->load_plugins( $class->plugins );

    bless {}, $class;
}

sub handler {
    my $self = shift;

    sub {
        my $env = shift;

        $env->{PATH_INFO} ||= '/';

        my $context = $self->context->new(
            env           => $env,
            dispatch_rule => +{},
            view          => $self->view,
            conf          => $self->container->get('conf'),
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

