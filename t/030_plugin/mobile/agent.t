use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Web::Handler;

my $plugins = [qw/Mobile::Agent/];
Kamui::Web::Context->load_plugins($plugins);

subtest 'non mobile test' => sub {
    my $env = +{
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/',
        HTTP_USER_AGENT => 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)',
    };

    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    isa_ok $c->mobile, 'HTTP::MobileAgent::NonMobile';
    ok $c->mobile->is_non_mobile;
    done_testing;
};

subtest 'docomo test' => sub {
    my $env = +{
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/',
        HTTP_USER_AGENT => 'DoCoMo/2.0 T2101V(c100)',
    };

    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    isa_ok $c->mobile, 'HTTP::MobileAgent::DoCoMo';
    ok $c->mobile->is_docomo;
    done_testing;
};

subtest 'ez test' => sub {
    my $env = +{
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/',
        HTTP_USER_AGENT => 'KDDI-TS21 UP.Browser/6.0.2.276 (GUI) MMP/1.1',
    };

    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    isa_ok $c->mobile, 'HTTP::MobileAgent::EZweb';
    ok $c->mobile->is_ezweb;
    done_testing;
};

subtest 'softbank test' => sub {
    my $env = +{
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/',
        HTTP_USER_AGENT => 'SoftBank/1.0/910T/TJ001/SNXXXXXXXXX Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1',
    };

    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    isa_ok $c->mobile, 'HTTP::MobileAgent::JPhone';
    ok $c->mobile->is_softbank;
    done_testing;
};

subtest 'airh test' => sub {
    my $env = +{
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/',
        HTTP_USER_AGENT => 'Mozilla/3.0(DDIPOCKET;JRC/AH-J3001V,AH-J3002V/1.0/0100/c50)CNF/2.0',
    };

    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    isa_ok $c->mobile, 'HTTP::MobileAgent::AirHPhone';
    ok $c->mobile->is_airh_phone;
    done_testing;
};

done_testing;
