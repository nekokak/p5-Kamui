use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Container;
use Mock::Web::Handler;

subtest 'html filter' => sub {
    my $c = Kamui::Web::Context->new(
        dispatch_rule => {
            controller => 'Mock::Web::Controller::Root',
            action     => 'filter',
            is_static  => 0,
            args       => {},
        },
        app  => 'Mock::Web::Handler',
        view => 'Kamui::View::TT',
        conf => container('conf'),
    );

    $c->add_filter(sub {
        my ($context, $res) = @_;
        (my $body = $res->body) =~ s/not //;
        $res->body($body);
        $res;
    });
    my $res = $c->render;
    isa_ok $res, 'Kamui::Web::Response';
    is $res->status, 200;
    is $res->body, "filter is ok\n";
    done_testing;
};

done_testing;

