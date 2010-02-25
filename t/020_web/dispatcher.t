use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Web::Dispatcher;

subtest 'maping' => sub {
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
    done_testing;
};

subtest 'maping' => sub {
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
    done_testing;
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

done_testing;

