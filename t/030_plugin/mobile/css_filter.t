use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Web::Handler;
use Mock::Container;

BEGIN {
    eval "use HTTP::MobileAgent";
    plan skip_all => 'needs HTTP::MobileAgent for testing' if $@;
    eval "use HTML::MobileJpCSS";
    plan skip_all => 'needs HTML::MobileJpCSS for testing' if $@;
};

my $plugins = [qw/Encode Mobile::Agent Mobile::CSSFilter/];
Kamui::Web::Context->load_plugins($plugins);

subtest 'non mobile test' => sub {
    my $env = +{
        REQUEST_METHOD  => 'GET',
        SCRIPT_NAME     => '/',
        HTTP_USER_AGENT => 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)',
    };

    my $c = Kamui::Web::Context->new(
        env  => $env,
        app  => 'Mock::Web::Handler',
        conf => container('conf'),
    );

    my $res = $c->res;
    $res->status('200');
    $res->headers([ 'Content-Type' => 'text/html' ]);
    $res->body('<html><head><link rel="stylesheet" href="/css/t.css" /></head><body>css filter</body></html>');

    $c->finalize($res);

    is $res->body, '<html><head><link rel="stylesheet" href="/css/t.css" /></head><body>css filter</body></html>';
    done_testing;
};

subtest 'docomo test' => sub {
    my $env = +{
        REQUEST_METHOD  => 'GET',
        SCRIPT_NAME     => '/',
        HTTP_USER_AGENT => 'DoCoMo/2.0 T2101V(c100)',
    };

    my $c = Kamui::Web::Context->new(
        env  => $env,
        app  => 'Mock::Web::Handler',
        conf => container('conf'),
    );

    my $res = $c->res;
    $res->status('200');
    $res->headers([ 'Content-Type' => 'text/html' ]);
    $res->body('<html><head><link rel="stylesheet" href="/css/t.css" /></head><body>css filter</body></html>');

    $c->finalize($res);

    is $res->body, '<html><head></head><body style="background-color:#ffffff;">css filter</body></html>';
    done_testing;
};

subtest 'ez test' => sub {
    my $env = +{
        REQUEST_METHOD  => 'GET',
        SCRIPT_NAME     => '/',
        HTTP_USER_AGENT => 'KDDI-TS21 UP.Browser/6.0.2.276 (GUI) MMP/1.1',
    };

    my $c = Kamui::Web::Context->new(
        env  => $env,
        app  => 'Mock::Web::Handler',
        conf => container('conf'),
    );

    my $res = $c->res;
    $res->status('200');
    $res->headers([ 'Content-Type' => 'text/html' ]);
    $res->body('<html><head><link rel="stylesheet" href="/css/t.css" /></head><body>css filter</body></html>');

    $c->finalize($res);

    is $res->body, '<html><head></head><body style="background-color:#ffffff;">css filter</body></html>';
    done_testing;
};

subtest 'softbank test' => sub {
    my $env = +{
        REQUEST_METHOD  => 'GET',
        SCRIPT_NAME     => '/',
        HTTP_USER_AGENT => 'SoftBank/1.0/910T/TJ001/SNXXXXXXXXX Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1',
    };

    my $c = Kamui::Web::Context->new(
        env  => $env,
        app  => 'Mock::Web::Handler',
        conf => container('conf'),
    );

    my $res = $c->res;
    $res->status('200');
    $res->headers([ 'Content-Type' => 'text/html' ]);
    $res->body('<html><head><link rel="stylesheet" href="/css/t.css" /></head><body>css filter</body></html>');

    $c->finalize($res);

    is $res->body, '<html><head></head><body style="background-color:#ffffff;">css filter</body></html>';
    done_testing;
};

subtest 'airh test' => sub {
    my $env = +{
        REQUEST_METHOD  => 'GET',
        SCRIPT_NAME     => '/',
        HTTP_USER_AGENT => 'Mozilla/3.0(DDIPOCKET;JRC/AH-J3001V,AH-J3002V/1.0/0100/c50)CNF/2.0',
    };

    my $c = Kamui::Web::Context->new(
        env  => $env,
        app  => 'Mock::Web::Handler',
        conf => container('conf'),
    );

    my $res = $c->res;
    $res->status('200');
    $res->headers([ 'Content-Type' => 'text/html' ]);
    $res->body('<html><head><link rel="stylesheet" href="/css/t.css" /></head><body>css filter</body></html>');

    $c->finalize($res);

    is $res->body, '<html><head></head><body style="background-color:#ffffff;">css filter</body></html>';
    done_testing;
};

done_testing;
