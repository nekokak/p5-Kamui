use t::Utils;
use Test::More;
use Mock::Web::Controller::HookTest;
use Kamui::Web::Context;

my $c = Kamui::Web::Context->new;

subtest 'register_hook' => sub {
    Mock::Web::Controller::HookTest->call_trigger('before_dispatch' => $c);
    is $c->stash->{before_dispatch_hook}, 'called';
    done_testing;
};
done_testing;
