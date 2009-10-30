use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'emoji filter tests' => run {
    init {
        my $plugins = [qw/Encode Mobile::EmojiFilter/];
        Kamui::Web::Context->load_plugins($plugins);
    };

    test 'emoji filter' => run {
        my $env = +{
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );

        my $res = $c->res;
        $res->status('200');
        $res->headers([ 'Content-Type' => 'text/html' ]);
        $res->body('{emoji:E21E}');

        $c->mobile_emoji_filter->finalize($res);

        is $res->body, "\x{e21e}";
    };

    test 'emoji filter' => run {
        my $env = +{
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
        };

        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );

        my $res = $c->res;
        $res->status('200');
        $res->headers([ 'Content-Type' => 'text/html' ]);
        $res->body('{emozi:E21E}');

        $c->mobile_emoji_filter->finalize($res);

        is $res->body, '{emozi:E21E}';
    };
};

