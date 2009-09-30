use t::Utils;
use Test::Declare;

plan tests => blocks;

describe 'request tests' => run {
    test 'can new' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/',
        };
        my $r = req($env);
        isa_ok $r, 'Kamui::Web::Request';
        isa_ok $r, 'Plack::Request';
    };

    test 'is_post_request / POST' => run {
        my $env = +{
            REQUEST_METHOD    => 'POST',
            SCRIPT_NAME       => '/foo',
        };
        my $r = req($env);
        ok $r->is_post_request;
    };

    test 'is_post_request / GET' => run {
        my $env = +{
            REQUEST_METHOD    => 'GET',
            SCRIPT_NAME       => '/foo',
        };
        my $r = req($env);
        ok not $r->is_post_request;
    };
};


