use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'detach tests' => run {
    test 'detach' => run {
        my $c = Kamui::Web::Context->new(
            app => 'Mock::Web::Handler',
        );
        throws_ok(sub {$c->detach}, qr/^KAMUI_DETACH at/);
    };

    test 'is_detach' => run {
        my $c = Kamui::Web::Context->new(
            app => 'Mock::Web::Handler',
        );
        ok not $c->is_detach(undef);
        eval {$c->detach};
        ok $c->is_detach($@);
    };
};

