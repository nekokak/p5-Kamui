use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Dispatcher;

plan tests => blocks;

describe 'dispatcher tests' => run {
    test 'maping' => run {
        my $env = +{
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
            PATH_INFO      => '/',
        };

        my $c = create_context($env);
        my $map = Mock::Web::Dispatcher->determine($c);
        is_deeply $map, {
            controller => 'Mock::Web::Controller::Root',
            action     => 'index',
            is_static  => 0,
            args       => {},
        };
    };
    test 'maping' => run {
        my $env = +{
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/foo',
            PATH_INFO      => '/foo',
        };

        my $c = create_context($env);
        my $map = Mock::Web::Dispatcher->determine($c);
        is_deeply $map, {
            controller => 'Mock::Web::Controller::Root',
            action     => 'index',
            is_static  => 0,
            args       => { p => 'foo'},
        };
    };
};


sub create_context {
    my $env = shift;
    return Kamui::Web::Context->new(
        env  => $env,
        dispatch_rule => undef,
        conf => undef,
        app  => 'Mock::Web::Handler',
    );
}
