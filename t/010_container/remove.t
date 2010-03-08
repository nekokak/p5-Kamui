use t::Utils;
use Mock::Container;
use Test::More;
use Data::Dumper;

subtest 'remove' => sub {
    my $foo = container('foo');
    Mock::Container->remove('foo');
    my $foo2 = container('foo');

    isnt $foo, $foo2;

    done_testing;
};

done_testing;

