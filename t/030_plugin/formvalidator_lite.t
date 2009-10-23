use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;

plan tests => blocks;

describe 'validation tests' => run {
    test 'validation' => run {
        my $env = +{
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
            QUERY_STRING   => 'p=query',
        };

        Kamui::Web::Context->load_plugins([qw/FormValidatorLite/]);
        my $c = Kamui::Web::Context->new(
            env => $env,
            dispatch_rule => {
                controller => 'Mock::Web::Controller::Root',
                action     => 'validator',
                is_static  => 0,
                args       => {},
            },
            view => 'Kamui::View::TT',
            conf => container('conf'),
            app  => 'Mock::Web::Handler',
        );

        my $validator = $c->validator->valid('foo')->add;
        ok $validator->has_error;
        ok $validator->get_error_messages;
    };
};
