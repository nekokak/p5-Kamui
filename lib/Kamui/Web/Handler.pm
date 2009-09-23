package Kamui::Web::Handler;
use Kamui;
use HTTP::Engine;
use HTTP::Engine::Middleware;
use UNIVERSAL::require;

sub new {
    my $class = shift;
    my $self = bless {}, $class;

    my $middlewares = HTTP::Engine::Middleware->new({ method_class => 'HTTP::Engine::Request' });
    $middlewares->install( @{container('conf')->{http_engine}->{middleware_setting}} );

    my $interface = container('conf')->{http_eigine}->{interface};
    $interface->{request_handler} = $middlewares->handler($self->request_handler);
    $self->{http_engine} = HTTP::Engine->new(interface => $interface);

    my $dispatcher_class = join '::', $self->base_name, 'Web', 'Dispatcher';
    $self->load_class($dispatcher_class); 
    $self->{dispatcher_class} = $dispatcher_class;

    $self;
}

sub run { $_[0]->{http_engine}->run }

sub request_handler {
    my $self = shift;
    sub { $self->handler(@_) }
}

sub handler {
    my ($self, $req) = @_;

    my $dispatcher_class = $self->{dispatcher_class};
    my $rule = $dispatcher_class->dispatch($req);
    $rule->{controller_class}->use;
    if ( $@ ) {
        warn $@;
        return $self->not_found;
    }

    my $method = $rule->{method};
    if ( $rule->{controller_class}->can($method) ) {

        my $res = $rule->{controller_class}->$method($self->context);
        unless (ref($res) eq'HTTP::Engine::Response') {

            my $view_class;
            unless ($self->context->{view_class}) {
                $view_class = $self->context->view($self->default_view);
            } else {
                $view_class = $self->context->view;
            }

            return $view_class->process($rule->{controller}, $rule->{action});

        } else {
            return $res;
        }

    } else {
        warn "method $method is not defined to @{[ $rule->{controller_class} ]}";
        return $self->not_found;
    }
}

sub not_found {
    my $self = shift;
    $self->context->res->status(404);
    $self->context->res->body('NOT FOUND');
}

1;

