use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;
use Mock::Web::Dispatcher;

plan tests => blocks;

describe 'guess_filename tests' => run {
    test 'guess_filename' => run {
        my $env = +{
            HTTP_HOST      => 'example.com',
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
            PATH_INFO      => '/',
            QUERY_STRING   => 'p=query',
        };

        my $c = Kamui::Web::Context->new(
            env  => $env,
            dispatch_rule => Mock::Web::Dispatcher->determine($env),
            conf => container('conf'),
            app  => 'Mock::Web::Handler',
        );
        is $c->guess_filename, 'root/index.html';
    };
};

