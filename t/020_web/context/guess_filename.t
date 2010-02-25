use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;
use Mock::Web::Dispatcher;

subtest 'guess_filename' => sub {
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
    is $c->guess_filename, 'root/index.html';
    done_testing;
};

done_testing;
