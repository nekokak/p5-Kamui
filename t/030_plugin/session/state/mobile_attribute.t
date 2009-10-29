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
            REQUEST_METHOD  => 'GET',
            SCRIPT_NAME     => '/',
            HTTP_USER_AGENT => 'DoCoMo/1.0/D504i/c10/TJ',
            HTTP_X_DCMGUID  => 'docomo_guid_foo',
            REMOTE_ADDR     => '210.153.84.1',
        };

        $c = Kamui::Web::Context->new(
            env  => $env,
            app  => 'Mock::Web::Handler',
            conf => container('conf'),
        );
        $c->conf->{plugins}->{session}->{state} = +{
            class  => 'Kamui::Plugin::Session::State::MobileAttributeID',
            option => +{},
        };
    };

    test 'Kamui::Plugin::Session::State::MobileAttributeID use MobileAttribute plugin' => run {
        dies_ok(sub {$c->session});
    };

    Kamui::Web::Context->load_plugins([qw/Mobile::Attribute/]);

    test 'basic test' => run {
        isa_ok $c->session, 'Kamui::Plugin::Session::Backend';
        isa_ok $c->session->{state}, 'Kamui::Plugin::Session::State::MobileAttributeID';
        isa_ok $c->session->{store}, 'Kamui::Plugin::Session::Store::Memory';
    };

    test 'state use MobileAttribute test' => run {
        is $c->session->{session_id}, 'docomo_guid_foo';
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
        ok $old_session_id eq $c->session->{session_id};

        is $c->session->get('foo'), 'baz';
    };

    test 'test finalize method' => run {
        ok $c->session->finalize($c->res);
    };

    init {
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
    };

    test 'next request test' => run {
        is $c->session->{session_id}, 'docomo_guid_foo';
        is $c->session->get('foo'), 'baz';
    };
};

