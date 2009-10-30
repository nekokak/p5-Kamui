use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'docomo guid filter tests' => run {

    init {
        my $plugins = [qw/Encode Mobile::Attribute Mobile::DoCoMoGUIDFilter/];
        Kamui::Web::Context->load_plugins($plugins);
    };

    test 'carrier docomo test' => run {
        my $env = +{
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
            HTTP_USER_AGENT => 'DoCoMo/2.0 T2101V(c100)',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );

        my $res = $c->res;
        $res->status('200');
        $res->headers([ 'Content-Type' => 'text/html' ]);
        $res->body('<a href="/">top</a>');

        $c->finalize($res);

        is $res->body, '<a href="/?guid=ON">top</a>';
    };

    test 'carrier ez test' => run {
        my $env = +{
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
            HTTP_USER_AGENT => 'KDDI-TS21 UP.Browser/6.0.2.276 (GUI) MMP/1.1',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );

        my $res = $c->res;
        $res->status('200');
        $res->headers([ 'Content-Type' => 'text/html' ]);
        $res->body('<a href="/">top</a>');

        $c->finalize($res);

        is $res->body, '<a href="/">top</a>';
    };

    test 'carrier softbank test' => run {
        my $env = +{
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
            HTTP_USER_AGENT => 'SoftBank/1.0/910T/TJ001/SNXXXXXXXXX Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );

        my $res = $c->res;
        $res->status('200');
        $res->headers([ 'Content-Type' => 'text/html' ]);
        $res->body('<a href="/">top</a>');

        $c->finalize($res);

        is $res->body, '<a href="/">top</a>';
    };

    test 'carrier airh test' => run {
        my $env = +{
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
            HTTP_USER_AGENT => 'Mozilla/3.0(DDIPOCKET;JRC/AH-J3001V,AH-J3002V/1.0/0100/c50)CNF/2.0',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );

        my $res = $c->res;
        $res->status('200');
        $res->headers([ 'Content-Type' => 'text/html' ]);
        $res->body('<a href="/">top</a>');

        $c->finalize($res);

        is $res->body, '<a href="/">top</a>';
    };

    test 'carrier none_mobile test' => run {
        my $env = +{
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
            HTTP_USER_AGENT => 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );

        my $res = $c->res;
        $res->status('200');
        $res->headers([ 'Content-Type' => 'text/html' ]);
        $res->body('<a href="/">top</a>');

        $c->finalize($res);

        is $res->body, '<a href="/">top</a>';
    };

};

