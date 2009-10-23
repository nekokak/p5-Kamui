use t::Utils;
use Test::Declare;
use Mock::Web::Handler;

plan tests => blocks;

my $app = Mock::Web::Handler->new;
$app->setup;
my $psgi_handler = $app->handler;

describe 'handler tests' => run {
    test 'simple handler test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SERVER_PROTOCOL   => 'HTTP/1.1',
            SERVER_PORT       => 80,
            SERVER_NAME       => 'example.com',
            SCRIPT_NAME       => '/handler_base_test',
            PATH_INFO         => '/handler_base_test',
            REMOTE_ADDR       => '127.0.0.1',
        };
        my $res = $psgi_handler->($env);
        isa_ok $res, 'Kamui::Web::Response';
        is $res->status, 200;
        is $res->content_type, 'text/html';
        is $res->body, "handler_base_test is ok\n";
    };

    test 'args test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SERVER_PROTOCOL   => 'HTTP/1.1',
            SERVER_PORT       => 80,
            SERVER_NAME       => 'example.com',
            SCRIPT_NAME       => '/args_test',
            PATH_INFO         => '/args_test',
            REMOTE_ADDR       => '127.0.0.1',
        };
        my $res = $psgi_handler->($env);
        isa_ok $res, 'Kamui::Web::Response';
        is $res->status, 200;
        is $res->content_type, 'text/html';
        is $res->body, "args_test is ok\n";
    };

    test 'query test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SERVER_PROTOCOL   => 'HTTP/1.1',
            SERVER_PORT       => 80,
            SERVER_NAME       => 'example.com',
            SCRIPT_NAME       => '/query_test/',
            PATH_INFO         => '/query_test/',
            REMOTE_ADDR       => '127.0.0.1',
            QUERY_STRING      => 'p=query',
        };
        my $res = $psgi_handler->($env);
        isa_ok $res, 'Kamui::Web::Response';
        is $res->status, 200;
        is $res->content_type, 'text/html';
        is $res->body, "query is ok\n";
    };
};

