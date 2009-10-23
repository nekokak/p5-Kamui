use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'handle_500 tests' => run {
    test 'handle_500' => run {
        my $c = Kamui::Web::Context->new(
            app => 'Mock::Web::Handler',
        );
        my $res = $c->handle_500;
        isa_ok $res, 'Kamui::Web::Response';
        is $res->status, '500';
        is $res->content_type, 'text/plain';
    };
};

