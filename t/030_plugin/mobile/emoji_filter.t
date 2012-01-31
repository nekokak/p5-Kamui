use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Web::Handler;

BEGIN {
    eval "use HTTP::MobileAgent";
    plan skip_all => 'needs HTTP::MobileAgent for testing' if $@;
};

my $plugins = [qw/Encode Mobile::EmojiFilter/];
Kamui::Web::Context->load_plugins($plugins);

subtest 'emoji filter' => sub {
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
    done_testing;
};

subtest 'emoji filter' => sub {
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
    done_testing;
};

done_testing;
