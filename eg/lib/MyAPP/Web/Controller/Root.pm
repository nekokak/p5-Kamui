package MyAPP::Web::Controller::Root;
use Kamui;

sub index {
    my ($class, $c, $args) = @_;
    $c->stash->{nick} = $c->req->param('nick') || 'nekokak';
    $c->stash->{name} = 'コバヤシアツシ';
    $c->stash->{args} = $args->{p};
}

1;

