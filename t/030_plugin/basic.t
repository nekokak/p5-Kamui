use t::Utils;
use Test::More;
use Test::Output;
use Kamui::Web::Context;
use Mock::Web::Handler;

Kamui::Web::Context->load_plugins([qw/Encode/]);

my $env = +{
    REQUEST_METHOD => 'GET',
    SCRIPT_NAME    => '/',
};

subtest 'basic test' => sub {
    my $plugins = [qw/+Mock::Plugin::Foo/];
    Kamui::Web::Context->load_plugins($plugins);
    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    is $c->foo->call, 'foo';
    done_testing;
};

subtest 'initialize test' => sub {
    my $plugins = [qw/+Mock::Plugin::Initialize/];
    Kamui::Web::Context->load_plugins($plugins);
    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    stdout_is(sub { $c->initialize }, 'call initialize hook');
    done_testing;
};

subtest 'finalize test' => sub {
    my $plugins = [qw/+Mock::Plugin::Finalize/];
    Kamui::Web::Context->load_plugins($plugins);
    my $c = Kamui::Web::Context->new(
        env => $env,
        app => 'Mock::Web::Handler',
    );
    $c->res->status('200');
    is $c->fin->call, 'finalize';
    stdout_is(sub { $c->finalize }, 'call finalize hook');
    done_testing;
};

done_testing;

