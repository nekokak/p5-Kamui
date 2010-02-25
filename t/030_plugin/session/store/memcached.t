use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;
use Cache::Memcached::Fast;

BEGIN {
    my $memd = Cache::Memcached::Fast->new({servers => ['127.0.0.1:11211']});
    my $version = $memd->server_versions;
    plan skip_all => 'can not access local memcached' unless scalar(keys %$version);
};

my $plugins = [qw/Session/];
Kamui::Web::Context->load_plugins($plugins);
my $env = +{
    REQUEST_METHOD => 'GET',
    SCRIPT_NAME    => '/',
};

my $c = Kamui::Web::Context->new(
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

subtest 'basic test' => sub {
    isa_ok $c->session, 'Kamui::Plugin::Session::Backend';
    isa_ok $c->session->{state}, 'Kamui::Plugin::Session::State::Cookie';
    isa_ok $c->session->{store}, 'Kamui::Plugin::Session::Store::Memcached';
    done_testing;
};

subtest 'session update flag off by only get' => sub {
    ok not $c->session->{session_updated};
    ok not $c->session->get('foo');
    ok not $c->session->{session_updated};
    done_testing;
};

subtest 'test set method and session update flag on' => sub {
    $c->session->set(foo => 'bar');
    is $c->session->get('foo'), 'bar';
    ok $c->session->{session_updated};
    $c->session->{session_updated} = 0;
    done_testing;
};

subtest 'test remove method and session update flag on' => sub {
    is $c->session->remove('foo'), 'bar';
    ok not $c->session->get('foo');
    ok $c->session->{session_updated};
    done_testing;
};

subtest 'test regenerate method' => sub {
    $c->session->set(foo => 'baz');

    ok $c->session->{session_id};
    my $old_session_id = $c->session->{session_id};
    $c->session->regenerate;
    ok $old_session_id ne $c->session->{session_id};

    is $c->session->get('foo'), 'baz';
    done_testing;
};

subtest 'test finalize method' => sub {
    $c->res->status(200);
    $c->session->finalize($c->res);
    ok $c->res->cookies;
    my $res = $c->res->finalize;
    is $res->[1]->[0], 'Set-Cookie';
    done_testing;
};

subtest 'next request test' => sub {
    my $prev_rquest_session_id = $c->session->{session_id};
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

    is $c->session->{session_id}, $prev_rquest_session_id;
    is $c->session->get('foo'), 'baz';
    done_testing;
};

done_testing;

