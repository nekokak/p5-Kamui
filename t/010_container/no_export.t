use t::Utils;
use Test::More;
use Mock::Container -no_export;

subtest 'no export container' => sub {
    ok not main->can('container');
    done_testing;
};

subtest 'new' => sub {
    my $obj = Mock::Container->instance;
    isa_ok $obj, 'Mock::Container';
    is_deeply $obj->get('conf')->{conf_test}, +{ foo => 'bar', name => 'nekokak' };
    done_testing;
};

done_testing;

