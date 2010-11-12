use t::Utils;
use Test::More;
use Test::Exception;
use Kamui::Web::Context;
use Mock::Web::Handler;

subtest 'detach' => sub {
    my $c = Kamui::Web::Context->new(
        app => 'Mock::Web::Handler',
    );
    throws_ok(sub {$c->detach}, qr/^KAMUI_DETACH at/);
    done_testing;
};

subtest 'is_detach' => sub {
    my $c = Kamui::Web::Context->new(
        app => 'Mock::Web::Handler',
    );
    ok not $c->is_detach(undef);
    eval {$c->detach};
    ok $c->is_detach($@);
    done_testing;
};

done_testing;
