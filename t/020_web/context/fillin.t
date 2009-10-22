use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Container;

plan tests => blocks;

describe 'fillin tests' => run {
    test 'fillin form' => run {
        my $c = Kamui::Web::Context->new(
            dispatch_rule => {
                controller => 'Mock::Web::Controller::Root',
                action     => 'fillin',
                is_static  => 0,
                args       => {},
            },
            view => 'Kamui::View::TT',
            conf => container('conf'),
        );
        $c->fillin_fdat({name => 'nekokak'});
        my $out = $c->render;
        chomp $out->[2]->[0];
        is_deeply $out,  [
          200,
          [
            'Content-Type',
            'text/html'
          ],
          [
            'my name is <input type="text" name="name" value="nekokak" />.'
          ]
        ];
    };
};

