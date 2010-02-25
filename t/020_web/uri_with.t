use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;

subtest 'uri_with' => sub {
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
    done_testing;
};
done_testing;

