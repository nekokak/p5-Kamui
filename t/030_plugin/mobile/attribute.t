use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'mobile attribute tests' => run {

    init {
        my $plugins = [qw/Mobile::Attribute/];
        Kamui::Web::Context->load_plugins($plugins);
    };

    test 'non mobile test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        isa_ok $c->mobile, 'HTTP::MobileAttribute::Agent::NonMobile';
        ok $c->mobile->is_non_mobile;
    };

    test 'docomo test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
            HTTP_USER_AGENT => 'DoCoMo/2.0 T2101V(c100)',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        isa_ok $c->mobile, 'HTTP::MobileAttribute::Agent::DoCoMo';
        ok $c->mobile->is_docomo;
    };

    test 'ez test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
            HTTP_USER_AGENT => 'KDDI-TS21 UP.Browser/6.0.2.276 (GUI) MMP/1.1',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        isa_ok $c->mobile, 'HTTP::MobileAttribute::Agent::EZweb';
        ok $c->mobile->is_ezweb;
    };

    test 'softbank test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
            HTTP_USER_AGENT => 'SoftBank/1.0/910T/TJ001/SNXXXXXXXXX Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        isa_ok $c->mobile, 'HTTP::MobileAttribute::Agent::ThirdForce';
        ok $c->mobile->is_softbank;
    };

    test 'non mobile test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
            HTTP_USER_AGENT => 'Mozilla/3.0(DDIPOCKET;JRC/AH-J3001V,AH-J3002V/1.0/0100/c50)CNF/2.0',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        isa_ok $c->mobile, 'HTTP::MobileAttribute::Agent::AirHPhone';
        ok $c->mobile->is_airh_phone;
    };

};


