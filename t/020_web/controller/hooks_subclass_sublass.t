use t::Utils;
use Test::More;
use Mock::Web::Controller::HookTest::Foo::Bar;
use Kamui::Web::Context;

subtest 'subclass subclass hook test' => sub {
    my $c = Kamui::Web::Context->new;
    Mock::Web::Controller::HookTest::Foo::Bar->call_trigger('before_dispatch' => $c);
    ok not $c->stash->{before_dispatch_hook};
    ok not $c->stash->{before_dispatch_hook_foo};
    is $c->stash->{before_dispatch_hook_foo_bar}, 'called';
    done_testing;
};

done_testing;
