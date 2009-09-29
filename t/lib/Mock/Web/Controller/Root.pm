package Mock::Web::Controller::Root;
use Kamui::Web::Controller;

sub dispatch_index {
    my ($class, $c, $args) = @_;
    $c->stash->{args} = $args->{p};
}

1;

