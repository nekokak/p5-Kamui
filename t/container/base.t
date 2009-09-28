use strict;
use warnings;
use Test::Declare;
use lib './t/lib';
use Mock::Container;

plan tests => blocks;

describe 'container tests' => run {

    test 'builtin container object: home' => run {
        my $home = container('home');
        ok $home , 'get home dir: '. $home;
    };

    test 'builtin container object: conf' => run {
        is_deeply container('conf')->{conf_test}, +{ foo => 'bar', name => 'nekokak' };
    };

    test 'export container function' => run {
        isa_ok container('foo'), 'Mock::Foo';
        is container('foo')->say, 'foo';
        dies_ok(sub { container('bar') }, q{can't get bar.});
    };
};


