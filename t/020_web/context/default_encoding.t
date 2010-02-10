use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;
use Mock::Web::Dispatcher;

plan tests => blocks;

describe 'default encoding tests' => run {
    test 'set default encoding module' => run {
        my $env = +{
            HTTP_HOST      => 'example.com',
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
            PATH_INFO      => '/',
            QUERY_STRING   => 'p=query',
        };

        my $c = Kamui::Web::Context->new(
            env  => $env,
            dispatch_rule => undef,
            conf => container('conf'),
            app  => 'Mock::Web::Handler',
        );
        my $rule = Mock::Web::Dispatcher->determine($c);
        $c->{dispatch_rule} = $rule;

        ok not $c->can('prepare_encoding');
        $c->initialize;
        can_ok $c, 'prepare_encoding';
    };
};

