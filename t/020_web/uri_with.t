use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;

plan tests => blocks;

describe 'uri_with tests' => run {
    test 'uri_with' => run {
        my $env = +{
            HTTP_HOST      => 'example.com',
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
            REQUEST_URI    => '/',
            QUERY_STRING   => 'p=query',
        };

        my $c = Kamui::Web::Context->new(
            env  => $env,
            conf => container('conf'),
            app  => 'Mock::Web::Handler',
        );
        is $c->uri_with({foo => 'bar'}), 'http://example.com/?p=query&foo=bar';
    };
};

