package Mock::Web::Controller::Test;
use Kamui::Web::Controller -base;

sub do_handler_base_test { }
sub do_query_test {
    my ($class, $c) = @_;
    $c->stash->{query} = $c->req->param('p');
}

1;

