use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;

plan tests => blocks;

describe 'plugin tests' => run {
    test 'basic test' => run {
        my $plugins = [qw/Session/];
        Kamui::Web::Context->load_plugins($plugins);

        my $env = +{
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
        };

        my $c = Kamui::Web::Context->new(
            env  => $env,
            app  => 'Mock::Web::Handler',
            conf => container('conf'),
        );
        my $session = $c->session;
        isa_ok $session, 'Kamui::Plugin::Session::Backend';
        isa_ok $session->{state}, 'Kamui::Plugin::Session::State::Cookie';
        isa_ok $session->{store}, 'Kamui::Plugin::Session::Store::Memory';
    };
};


