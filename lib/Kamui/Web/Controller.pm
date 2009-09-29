package Kamui::Web::Controller;
use Kamui;

sub import {
    my $caller = caller(0);

    my $pkg = caller(0);
    for my $meth ( qw/register_hook call_hook/ ) {
        no strict 'refs';
        *{"$pkg\::$meth"} = \&$meth;
    }

    goto &Kamui::import;
}

my $HOOKS = +{};
my $HOOKABLE_POINT = +{
    before_dispatch => 1,
    after_dispatch  => 1,
};

sub register_hook ($&) { ## no critic.
    my ($hook_point, $code) = @_;
    my $caller = caller(0);

    if ($HOOKABLE_POINT->{$hook_point}) {
        push @{$HOOKS->{$caller}->{$hook_point}} , $code;
    } else {
        die qq{can't hook: $hook_point};
    }
}

sub call_hook {
    my ($class, $hook_point, $context) = @_;

    for my $code (@{$HOOKS->{$class}->{$hook_point}}) {
        $code->($context);
    }
}

1;

