use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;

plan tests => blocks;

describe 'plugin tests' => run {

    my $c;
    init {
        my $plugins = [qw/Session/];
        Kamui::Web::Context->load_plugins($plugins);
        my $env = +{
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
        };

        $c = Kamui::Web::Context->new(
            env  => $env,
            app  => 'Mock::Web::Handler',
            conf => container('conf'),
        );
        $c->conf->{plugins}->{session}->{store} = +{
            class  => 'Kamui::Plugin::Session::Store::Memcached',
            option => +{
                servers    => ['127.0.0.1:11211'],
                namespace  => 'kamui_test:',
                expire_for => 10,
            },
        };
    };

    test 'basic test' => run {
        isa_ok $c->session, 'Kamui::Plugin::Session::Backend';
        isa_ok $c->session->{state}, 'Kamui::Plugin::Session::State::Cookie';
        isa_ok $c->session->{store}, 'Kamui::Plugin::Session::Store::Memcached';
    };

    test 'session update flag off by only get' => run {
        ok not $c->session->{session_updated};
        ok not $c->session->get('foo');
        ok not $c->session->{session_updated};
    };

    test 'test set method and session update flag on' => run {
        $c->session->set(foo => 'bar');
        is $c->session->get('foo'), 'bar';
        ok $c->session->{session_updated};
        $c->session->{session_updated} = 0;
    };

    test 'test remove method and session update flag on' => run {
        is $c->session->remove('foo'), 'bar';
        ok not $c->session->get('foo');
        ok $c->session->{session_updated};
    };

    test 'test regenerate method' => run {
        $c->session->set(foo => 'baz');

        ok $c->session->{session_id};
        my $old_session_id = $c->session->{session_id};
        $c->session->regenerate;
        ok $old_session_id ne $c->session->{session_id};

        is $c->session->get('foo'), 'baz';
    };

    test 'test finalize method' => run {
        $c->res->status(200);
        $c->session->finalize($c->res);
        ok $c->res->cookies;
        my $res = $c->res->finalize;
        is $res->[1]->[0], 'Set-Cookie';
    };

    my $prev_rquest_session_id = $c->session->{session_id};
    init {
        my $env = +{
            HTTP_COOKIE    => $c->res->header('Set-Cookie'),
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
        };
        $c = Kamui::Web::Context->new(
            env  => $env,
            app  => 'Mock::Web::Handler',
            conf => container('conf'),
        );
    };

    test 'next request test' => run {
        is $c->session->{session_id}, $prev_rquest_session_id;
        is $c->session->get('foo'), 'baz';
    };
};

