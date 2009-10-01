use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;

plan tests => blocks;

describe 'filter tests' => run {
    test 'html filter' => run {
        my $c = Kamui::Web::Context->new(
            req => sub {},
            dispatch_rule => {
                controller => 'Mock::Web::Controller::Root',
                action     => 'filter',
                is_static  => 0,
                args       => {},
            },
            view => 'Kamui::View::TT',
            conf          => container('conf'),
        );

        $c->add_filter(sub {
            my ($context, $res) = @_;
            $res->[2]->[0] =~ s/not //;
            chomp $res->[2]->[0];
            $res;
        });
        my $out = $c->render;
        is_deeply $out,  [
          200,
          [
            'Content-Type',
            'text/html'
          ],
          [
            'filter is ok'
          ]
        ];
    };
};

