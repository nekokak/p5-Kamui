use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'plugin tests' => run {
    test 'basic test' => run {
        my $plugins = [qw/MobileAttribute/];
        Kamui::Web::Context->load_plugins($plugins);

        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        isa_ok $c->mobile_attribute, 'HTTP::MobileAttribute::Agent::NonMobile';
    };
};


