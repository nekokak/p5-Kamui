package Mock::Web::Controller::HookTest::Baz;
use Mock::Web::Controller::HookTest -base;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub {
        my ($class, $c) = @_;
        $c->stash->{before_dispatch_hook_baz} = 'called';
    },
);

1;

