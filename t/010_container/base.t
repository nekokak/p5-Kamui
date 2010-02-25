use t::Utils;
use Test::More;
use Test::Exception;
use Mock::Container;

subtest 'builtin container object: home' => sub {
    my $home = container('home');
    ok $home , 'get home dir: '. $home;
    done_testing;
};

subtest 'builtin container object: conf' => sub {
    is_deeply container('conf')->{conf_test}, +{ foo => 'bar', name => 'nekokak' };
    done_testing;
};

subtest 'export container function' => sub {
    isa_ok container('foo'), 'Mock::Foo';
    is container('foo')->say, 'foo';
    dies_ok(sub { container('bar') }, q{can't get bar.});
    done_testing;
};

done_testing;


