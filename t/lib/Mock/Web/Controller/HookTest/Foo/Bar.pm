package Mock::Web::Controller::HookTest::Foo::Bar;
use Mock::Web::Controller::HookTest::Foo -base;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub {
        my ($class, $c) = @_;
        $c->stash->{before_dispatch_hook_foo_bar} = 'called';
    },
);

1;

