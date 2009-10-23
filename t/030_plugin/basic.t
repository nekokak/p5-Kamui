use t::Utils;
use Test::Declare;
use Kamui::Web::Context;

plan tests => blocks;

describe 'plugin tests' => run {
    test 'basic test' => run {
        my $plugins = [qw/+Mock::Plugin::Foo/];
        Kamui::Web::Context->load_plugins($plugins);
        my $c = Kamui::Web::Context->new;
        is $c->foo->call, 'foo';
    };

    test 'finalize test' => run {
        my $plugins = [qw/+Mock::Plugin::Finalize/];
        Kamui::Web::Context->load_plugins($plugins);
        my $c = Kamui::Web::Context->new;
        is $c->fin->call, 'finalize';
        stdout_is(sub { $c->finalize }, 'call finalize hook');
    };
};

