use t::Utils;
use Test::Declare;
use Mock::Container qw/api/;

plan tests => blocks;

describe 'container tests' => run {

    test 'export api function' => run {
        isa_ok api('baz'), 'Mock::Api::Baz';
        is api('baz')->say, 'baz';
        dies_ok(sub { api('hoge') }, q{can't get hoge.});
    };
};


