use t::Utils;
use Test::Declare;
use Mock::Web::Controller::HookTest;
use Kamui::Web::Context;

plan tests => blocks;

my $c = Kamui::Web::Context->new;

describe 'hook test' => run {
    test 'register_hook' => run {
        Mock::Web::Controller::HookTest->call_trigger('before_dispatch' => $c);
        is $c->stash->{before_dispatch_hook}, 'called';
    };
};
