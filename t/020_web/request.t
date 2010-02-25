use t::Utils;
use Test::More;

subtest 'can new' => sub {
    my $env = +{
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/',
    };
    my $r = req($env);
    isa_ok $r, 'Kamui::Web::Request';
    isa_ok $r, 'Plack::Request';
    done_testing;
};

subtest 'is_post_request / POST' => sub {
    my $env = +{
        REQUEST_METHOD    => 'POST',
        SCRIPT_NAME       => '/foo',
    };
    my $r = req($env);
    ok $r->is_post_request;
    done_testing;
};

subtest 'is_post_request / GET' => sub {
    my $env = +{
        REQUEST_METHOD    => 'GET',
        SCRIPT_NAME       => '/foo',
    };
    my $r = req($env);
    ok not $r->is_post_request;
    done_testing;
};

done_testing;


