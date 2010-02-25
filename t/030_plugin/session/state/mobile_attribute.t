use t::Utils;
use Test::More;
use Test::Exception;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;

my $plugins = [qw/Session/];
Kamui::Web::Context->load_plugins($plugins);
my $env = +{
    REQUEST_METHOD  => 'GET',
    SCRIPT_NAME     => '/',
    HTTP_USER_AGENT => 'DoCoMo/1.0/D504i/c10/TJ',
    HTTP_X_DCMGUID  => 'docomo_guid_foo',
    REMOTE_ADDR     => '210.153.84.1',
};

my $c = Kamui::Web::Context->new(
    env  => $env,
    app  => 'Mock::Web::Handler',
    conf => container('conf'),
);
$c->conf->{plugins}->{session}->{state} = +{
    class  => 'Kamui::Plugin::Session::State::MobileAttributeID',
    option => +{},
};

subtest 'Kamui::Plugin::Session::State::MobileAttributeID use MobileAttribute plugin' => sub {
    dies_ok(sub {$c->session});
    done_testing;
};

Kamui::Web::Context->load_plugins([qw/Mobile::Attribute/]);

subtest 'basic test' => sub {
    isa_ok $c->session, 'Kamui::Plugin::Session::Backend';
    isa_ok $c->session->{state}, 'Kamui::Plugin::Session::State::MobileAttributeID';
    isa_ok $c->session->{store}, 'Kamui::Plugin::Session::Store::Memory';
    done_testing;
};

subtest 'state use MobileAttribute test' => sub {
    is $c->session->{session_id}, 'docomo_guid_foo';
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
    ok $old_session_id eq $c->session->{session_id};

    is $c->session->get('foo'), 'baz';
    done_testing;
};

subtest 'test finalize method' => sub {
    ok $c->session->finalize($c->res);
    done_testing;
};

subtest 'next request test' => sub {
    my $env = +{
        REQUEST_METHOD => 'GET',
        SCRIPT_NAME    => '/',
        HTTP_USER_AGENT => 'DoCoMo/1.0/D504i/c10/TJ',
        HTTP_X_DCMGUID  => 'docomo_guid_foo',
        REMOTE_ADDR     => '210.153.84.1',
    };
    $c = Kamui::Web::Context->new(
        env  => $env,
        app  => 'Mock::Web::Handler',
        conf => container('conf'),
    );

    is $c->session->{session_id}, 'docomo_guid_foo';
    is $c->session->get('foo'), 'baz';
    done_testing;
};

done_testing;

