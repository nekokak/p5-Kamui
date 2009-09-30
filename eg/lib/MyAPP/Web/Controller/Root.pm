package MyAPP::Web::Controller::Root;
use Kamui::Web::Controller -base;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub{
        my ($class, $c) = @_;
        $c->stash->{before_dispatch} = 'before_dispatch_ok';
    },
);

__PACKAGE__->add_trigger(
    'after_dispatch' => sub{
        my ($class, $c) = @_;
        $c->stash->{after_dispatch} = 'after_dispatch_ok';
    },
);

sub dispatch_index {
    my ($class, $c, $args) = @_;
    $c->stash->{nick} = $c->req->param('nick') || 'nekokak';
    $c->stash->{name} = 'コバヤシアツシ';
    if ($args->{p} eq 'do_redirect') {
        return $c->redirect('/redirect_done');
    } else {
        $c->stash->{args} = $args->{p};
    }

    $c->foo; # call plugin method;

    if ($c->req->is_post_request) {
        $c->stash->{method} = 'post';
    } else {
        $c->stash->{method} = 'get';
    }
}

sub dispatch_json {
    my ($class, $c) = @_;
    $c->stash->{json} = +{name => 'nekokak'};
    $c->view('JSON');
}

1;

