package MyAPP::Web::Controller::Foo;
use Kamui::Web::Controller -base;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub{
        my ($class, $c) = @_;
        $c->stash->{mode} = 'static';
    },
);

1;

