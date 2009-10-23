use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'redirect tests' => run {
    test 'redirect' => run {
        my $c = Kamui::Web::Context->new(
            app => 'Mock::Web::Handler',
        );
        throws_ok(sub {$c->redirect('/')}, qr/^KAMUI_DETACH at/);
        my $res = $c->res;
        isa_ok $res, 'Kamui::Web::Response';
        is $res->status, '302';
        is $res->location, '/';
        ok $c->is_finished;
    };
};

