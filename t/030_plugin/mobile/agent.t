use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

TODO: {
    local $TODO = "mobile agent is not finished";

    describe 'mobile agent tests' => run {
        test 'mobile agent test' => run {
            my $plugins = [qw/Mobile::Agent/];
            Kamui::Web::Context->load_plugins($plugins);

            my $env = +{
                REQUEST_METHOD    => 'GET',
                SCRIPT_NAME       => '/',
            };

            my $c = Kamui::Web::Context->new(
                env => $env,
                app => 'Mock::Web::Handler',
            );
            isa_ok $c->mobile, 'HTTP::MobileAgent';
        };
    };
};

