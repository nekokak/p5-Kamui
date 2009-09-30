use t::Utils;
use Test::Declare;
use Mock::Web::Controller::HookTest::Foo::Bar;
use Kamui::Web::Context;

plan tests => blocks;


describe 'hook test' => run {
    test 'subclass subclass hook test' => run {
        my $c = Kamui::Web::Context->new;
        Mock::Web::Controller::HookTest::Foo::Bar->call_trigger('before_dispatch' => $c);
        is $c->stash->{before_dispatch_hook}, 'called';
        is $c->stash->{before_dispatch_hook_foo}, 'called';
        is $c->stash->{before_dispatch_hook_foo_bar}, 'called';
    };
};
