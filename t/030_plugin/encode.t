use t::Utils;
use utf8;
use Plack::Test;
use Test::More;
use Kamui::Web::Context;
use Mock::Web::Handler;
use HTTP::Request::Common;

subtest 'plugin tests / get encode' => sub {

    my $env;
    Kamui::Web::Context->load_plugins([qw/Encode/]);

    open my $in, '<', \do { my $d };
    $env = +{
        'psgi.version'    => [ 1, 0 ],
        'psgi.input'      => $in,
        'psgi.errors'     => *STDERR,
        'psgi.url_scheme' => 'http',
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/',
        QUERY_STRING      => 'foo=%E6%97%A5%E6%9C%AC%E8%AA%9E&bar=%E6%97%A5%E6%9C%AC%E8%AA%9E&bar=%E6%97%A5%E6%9C%AC%E8%AA%9E',
    };

    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    $c->initialize;

    ok $c->req->param('foo');
    is $c->req->param('foo'), '日本語';
    my @bar = $c->req->param('bar');
    is_deeply \@bar, ['日本語','日本語'];

    done_testing;
};

subtest 'plugin tests / post encode' => sub {
    my $app = sub {
        my $env = shift;;
        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        $c->initialize;

        is(length $c->req->param('foo'), 3);
        my $res = $c->res;
        $res->status(200);
        $res->finalize;
    };

    test_psgi ( $app,
        sub {
            my $cb = shift;
            my $res = $cb->( POST "/", { foo => "日本語" });
            ok( $res->is_success );
        }
    );
    done_testing;
};

done_testing;

