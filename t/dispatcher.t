use strict;
use warnings;
use Test::Declare;
use lib './t/lib';
use Mock::Web::Dispatcher;
use HTTP::Request;
use Plack::Request;

plan tests => blocks;

describe 'dispatcher tests' => run {
    test 'maping' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SERVER_PROTOCOL   => 'HTTP/1.1',
            SERVER_PORT       => 80,
            SERVER_NAME       => 'example.com',
            SCRIPT_NAME       => '/',
            REMOTE_ADDR       => '127.0.0.1',
        };
        my $r = Plack::Request->new($env);

        my $map = Mock::Web::Dispatcher->determine($r);
        is_deeply $map, {
            controller => 'Mock::Web::Controller::Root',
            action     => 'index',
            is_static  => 0,
            args       => {},
        };
    };
    test 'maping' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SERVER_PROTOCOL   => 'HTTP/1.1',
            SERVER_PORT       => 80,
            SERVER_NAME       => 'example.com',
            SCRIPT_NAME       => '/foo',
            REMOTE_ADDR       => '127.0.0.1',
        };
        my $r = Plack::Request->new($env);

        my $map = Mock::Web::Dispatcher->determine($r);
        is_deeply $map, {
            controller => 'Mock::Web::Controller::Root',
            action     => 'index',
            is_static  => 0,
            args       => { p => 'foo'},
        };
    };
};


