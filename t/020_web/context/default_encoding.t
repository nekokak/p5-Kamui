use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;
use Mock::Web::Dispatcher;


subtest 'set default encoding module' => sub {
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
    done_testing;
};

done_testing;
