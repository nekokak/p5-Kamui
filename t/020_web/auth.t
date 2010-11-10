use t::Utils;
use Test::More;
use Kamui::Web::Context;
use Mock::Container;

{
    package Mock::Web::Controller::AuthTest1;
    use Kamui::Web::Controller -base;
    __PACKAGE__->authorizer('+Mock::Web::Authorizer::Test1');
    sub do_index {}

    package Mock::Web::Controller::AuthTest2;
    use Kamui::Web::Controller -base;
    __PACKAGE__->authorizer('+Mock::Web::Authorizer::Test2');
    sub do_index {}
    sub do_hoge : Auth('+Mock::Web::Authorizer::Test1') {}
}

{
    my $c = Kamui::Web::Context->new(
        dispatch_rule => {
            controller => 'Mock::Web::Controller::AuthTest1',
            action     => 'index',
            is_static  => 0,
            args       => {},
        },
        app  => 'Mock::Web',
        view => 'Kamui::View::TT',
        conf => container('conf'),
    );
    my $code = Mock::Web::Controller::AuthTest1->can('do_index');
    is +Mock::Web::Controller::AuthTest1->authorize($code, $c), 'Mock::Web::Authorizer::Test1';
}

{
    my $c = Kamui::Web::Context->new(
        dispatch_rule => {
            controller => 'Mock::Web::Controller::AuthTest2',
            action     => 'index',
            is_static  => 0,
            args       => {},
        },
        app  => 'Mock::Web',
        view => 'Kamui::View::TT',
        conf => container('conf'),
    );
    my $code = Mock::Web::Controller::AuthTest2->can('do_index');
    is +Mock::Web::Controller::AuthTest2->authorize($code, $c), 'Mock::Web::Authorizer::Test2';
}

{
    my $c = Kamui::Web::Context->new(
        dispatch_rule => {
            controller => 'Mock::Web::Controller::AuthTest2',
            action     => 'index',
            is_static  => 0,
            args       => {},
        },
        app  => 'Mock::Web',
        view => 'Kamui::View::TT',
        conf => container('conf'),
    );
    my $code = Mock::Web::Controller::AuthTest2->can('do_hoge');
    is +Mock::Web::Controller::AuthTest2->authorize($code, $c), 'Mock::Web::Authorizer::Test1';
}

done_testing;

