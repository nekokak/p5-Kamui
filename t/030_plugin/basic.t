use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'plugin tests' => run {

    my $env;
    init {
        Kamui::Web::Context->load_plugins([qw/Encode/]);

        $env = +{
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
        };
    };

    test 'basic test' => run {
        my $plugins = [qw/+Mock::Plugin::Foo/];
        Kamui::Web::Context->load_plugins($plugins);
        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        is $c->foo->call, 'foo';
    };

    test 'initialize test' => run {
        my $plugins = [qw/+Mock::Plugin::Initialize/];
        Kamui::Web::Context->load_plugins($plugins);
        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        stdout_is(sub { $c->initialize }, 'call initialize hook');
    };

    test 'finalize test' => run {
        my $plugins = [qw/+Mock::Plugin::Finalize/];
        Kamui::Web::Context->load_plugins($plugins);
        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        is $c->fin->call, 'finalize';
        stdout_is(sub { $c->finalize }, 'call finalize hook');
    };
};

