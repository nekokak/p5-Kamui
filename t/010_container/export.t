use t::Utils;
use Mock::Container qw/api form/;
use Test::More;
use Test::Exception;

subtest 'export api function' => sub {
    isa_ok api('baz'), 'Mock::Api::Baz';
    is api('baz')->say, 'baz';
    dies_ok(sub { api('hoge') }, q{can't get hoge.});
    done_testing;
};

subtest 'export form' => sub {
    isa_ok form('foo'), 'Mock::Api::Form::Foo';
    is form('foo')->say, 'foo';
    done_testing;
};

done_testing;

