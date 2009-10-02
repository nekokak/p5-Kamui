use t::Utils;
use Test::Declare;
use Kamui::Web::Context;

plan tests => blocks;

describe 'plugin tests' => run {
    test 'basic test' => run {
        my $plugins = [qw/MobileAttribute/];
        Kamui::Web::Context->load_plugins($plugins);
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
        };
        my $r = req($env);

        my $c = Kamui::Web::Context->new(
            req => $r,
        );
        isa_ok $c->mobile_attribute, 'HTTP::MobileAttribute::Agent::NonMobile';
    };
};


