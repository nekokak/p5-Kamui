package Kamui::Web::Dispatcher;
use Kamui;
use String::CamelCase qw/camelize/;
use constant TRUE => 1;
use constant FALSE => 0;
use Class::Data::Inheritable;

sub import {
    my $caller = caller(0);

    no strict 'refs';
    unshift @{"$caller\::ISA"}, 'Class::Data::Inheritable';
    $caller->mk_classdata('dispatch_table' => []);
    *{"$caller\::$_"} = *{$_} for qw/on run camelize_path determine TRUE FALSE/;
}

sub on ($$)  { ## no critic.
    my $class = caller(0);
    $class->dispatch_table( [@{$class->dispatch_table}, { regexp => qr{^$_[0]$}, code => $_[1] }] );
}

sub run (&) {shift} ## no critic.

my $camelize_path_cache;
sub camelize_path {
    my $path = shift;
    if (my $class = $camelize_path_cache->{$path}) {
        return $class;
    } else {
        $camelize_path_cache->{$path} = join '::', map {camelize $_} split '/', $path;
        return $camelize_path_cache->{$path};
    }
}

sub determine {
    my ($class, $r) = @_;

    for my $dispatch_rule (@{$class->dispatch_table}) {
        if ($r->path =~ $dispatch_rule->{regexp}) {
            my ($controller, $page, $static, $args) = $dispatch_rule->{code}->();
            if ($controller) {
                $controller = join '::', $class->base_name, 'Web', 'Controller', $controller;
                return +{
                    controller => $controller,
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

__END__

package Your::Web::Dispatcher;
use Kamui;
use Kamui::Web::Dispatcher;

on '/(.+?)/' => run {
    return 'Foo', 'index', FALSE, +{}
};

1;


