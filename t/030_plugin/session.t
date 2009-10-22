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
            QUERY_STRING   => 'p=query',
        };

        my $c = Kamui::Web::Context->new(
            env  => $env,
            app  => 'Mock::Web::Handler',
            conf => container('conf'),
        );
        isa_ok $c->session, 'HTTP::Session';
    };
};


