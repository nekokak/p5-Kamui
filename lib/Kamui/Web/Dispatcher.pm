package Kamui::Web::Dispatcher;
use Kamui;

sub import {
    my $caller = caller(0);

    {
        no strict 'refs';
        *{"$caller\::$_"} = *{$_} for qw/on run determine TRUE FALSE/;
        my $_dispatch_table = [];
        *{"$caller\::_dispatch_table"} = sub {
            my ($class, $table) = @_;
            $_dispatch_table = $table if $table;
            $_dispatch_table;
        }
    }

    goto &Kamui::import;
}

sub TRUE()  { 1 }
sub FALSE() { 0 }

sub on ($$)  { ## no critic.
    my $class = caller(0);
    $class->_dispatch_table([@{$class->_dispatch_table}, { regexp => qr{^$_[0]$}, code => $_[1] }]);
}

sub run (&) {shift} ## no critic.

sub determine {
    my ($class, $context) = @_;
    my $env = $context->{env};

    for my $dispatch_rule (@{$class->_dispatch_table}) {
        if ($env->{PATH_INFO} =~ $dispatch_rule->{regexp}) {
            my ($controller, $page, $static, $args) = $dispatch_rule->{code}->($context);
            if ($controller) {
                return +{
                    controller => join('::', $class->base_name, 'Web', 'Controller', $controller),
                    action     => $page,
                    is_static  => $static,
                    args       => $args
                };
            } else {
                return;
            }
        }
    }
    return;
}

1;

