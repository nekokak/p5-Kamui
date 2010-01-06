use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => blocks;

describe 'plugin tests' => run {

    my $env;
    init {
        Kamui::Web::Context->load_plugins([qw/Encode/]);

        open my $in, '<', \do { my $d };
        $env = +{
            'psgi.version'    => [ 1, 0 ],
            'psgi.input'      => $in,
            'psgi.errors'     => *STDERR,
            'psgi.url_scheme' => 'http',
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
        };
    };

    test 'basic test' => run {
        my $c = Kamui::Web::Context->new(
            env => $env,
            app => 'Mock::Web::Handler',
        );
        $c->req->body_parameters(var => 'あいうえお');
        $c->initialize;
        my $params = $c->req->parameters;
        ok Encode::is_utf8($params->{var});
    };
};

