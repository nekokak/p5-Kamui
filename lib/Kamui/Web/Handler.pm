package Kamui::Web::Handler;
use Kamui;
use Kamui::Web::Context;
use Kamui::Web::Controller;
use Plack::Request;
use UNIVERSAL::require;

sub new {
    my $class = shift;

    my $container = join '::', $class->base_name, 'Container';
    $container->use or die $@;

    bless {}, $class;
}

sub psgi_handler {
    my $self = shift;

    sub {
        my $env = shift;

        my $req  = Plack::Request->new($env);

        my $dispatcher = $self->{dispatch_class} ||= do {
            my $dispatch_class = join '::', $self->base_name, 'Web', 'Dispatcher';
            $dispatch_class->require or die "can't find dispatcher : $@";
            $dispatch_class;
        };

        my $rule = $dispatcher->determine($req);

        my $context = Kamui::Web::Context->new(
            req           => $req,
            app           => $self,
            dispatch_rule => $rule,
            conf          => container('conf'),
        );

        return Kamui::Web::Controller->dispatch($context);
    };
}

1;

