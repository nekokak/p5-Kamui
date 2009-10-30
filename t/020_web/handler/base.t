use t::Utils;
use Test::Declare;
use Mock::Web::Handler;
use Kamui::Web::Context;

plan tests => blocks;

describe 'handler tests' => run {
    my $psgi_handler;

    init {
        Kamui::Web::Context->load_plugins([qw/Encode/]);
        my $app = Mock::Web::Handler->new;
        $app->setup;
        $psgi_handler = $app->handler;
    };

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
        is_deeply $res, [
            '200',
            [
                'Content-Type',
                'text/html'
            ],
            [
                "handler_base_test is ok\n"
            ]
        ];
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
        is_deeply $res, [
            '200',
            [
                'Content-Type',
                'text/html'
            ],
            [
                "args_test is ok\n"
            ]
        ];
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
        is_deeply $res, [
            '200',
            [
                'Content-Type',
                'text/html'
            ],
            [
                "query is ok\n"
            ]
        ];
    };
};

