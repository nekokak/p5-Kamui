use strict;
use warnings;
use lib qw(./t/lib);
use Test::Declare;
use Mock::Web::Handler;

plan tests => blocks;

my $psgi_handler = Mock::Web::Handler->new->psgi_handler;

describe 'handler tests' => run {
    test 'simple handler test' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SERVER_PROTOCOL   => 'HTTP/1.1',
            SERVER_PORT       => 80,
            SERVER_NAME       => 'example.com',
            SCRIPT_NAME       => '/handler_base_test',
            REMOTE_ADDR       => '127.0.0.1',
        };
        my $out = $psgi_handler->($env);
        is_deeply $out,[
            200,
            [
              'Content-Type',
              'text/html'
            ],
            [
              'handler_base_test is ok
'
            ]
        ];
    };
};

