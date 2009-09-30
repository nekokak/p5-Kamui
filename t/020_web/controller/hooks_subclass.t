use t::Utils;
use Test::Declare;
use Mock::Web::Controller::HookTest::Foo;
use Mock::Web::Controller::HookTest::Baz;
use Kamui::Web::Context;

plan tests => blocks;

describe 'hook test' => run {
    test 'subclass hook test' => run {
        my $c = Kamui::Web::Context->new;

        Mock::Web::Controller::HookTest::Foo->call_trigger('before_dispatch' => $c);
        is $c->stash->{before_dispatch_hook}, 'called';
        is $c->stash->{before_dispatch_hook_foo}, 'called';
        ok not $c->stash->{before_dispatch_hook_baz};
    };
    test 'subclass hook test' => run {
        my $c = Kamui::Web::Context->new;

        Mock::Web::Controller::HookTest::Baz->call_trigger('before_dispatch' => $c);
        is $c->stash->{before_dispatch_hook}, 'called';
        is $c->stash->{before_dispatch_hook_baz}, 'called';
        ok not $c->stash->{before_dispatch_hook_foo};
    };
};
