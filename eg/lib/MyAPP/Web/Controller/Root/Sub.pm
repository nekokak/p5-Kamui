package MyAPP::Web::Controller::Root::Sub;
use MyAPP::Web::Controller::Root -base;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub{
        my ($class, $c) = @_;
        $c->stash->{before_dispatch} = 'before_dispatch_ok sub_class';
    },
);

__PACKAGE__->add_trigger(
    'after_dispatch' => sub{
        my ($class, $c) = @_;
        $c->stash->{after_dispatch} = 'after_dispatch_ok sub_class';
    },
);

sub do_index {
    my ($class, $c, $args) = @_;
    $c->stash->{nick} = $c->req->param('nick') || 'nekokak';
    $c->stash->{name} = 'コバヤシアツシ';
    if ($args->{p} eq 'do_redirect') {
        return $c->redirect('/redirect_done');
    } else {
        $c->stash->{args} = $args->{p};
    }
}

1;

