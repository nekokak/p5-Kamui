package Mock::Web::Controller::Test;
use Kamui::Web::Controller -base;

sub dispatch_handler_base_test { }
sub dispatch_query_test {
    my ($class, $c) = @_;
    $c->stash->{query} = $c->req->param('p');
}

1;

