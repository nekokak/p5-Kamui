use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Web::Handler;

subtest 'handle_404' => sub {
    my $c = Kamui::Web::Context->new(
        app => 'Mock::Web::Handler',
    );
    my $res = $c->handle_404;
    isa_ok $res, 'Kamui::Web::Response';
    is $res->status, '404';
    is $res->content_type, 'text/plain';
    done_testing;
};

done_testing;
