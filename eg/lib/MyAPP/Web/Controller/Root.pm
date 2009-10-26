package MyAPP::Web::Controller::Root;
use Kamui::Web::Controller -base;
use HTTP::MobileAttribute plugins => [qw/IS/];
use Encode;

#__PACKAGE__->authorizer('+MyAPP::Web::Authorizer::BasicAuth');

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

sub do_index {
    my ($class, $c, $args) = @_;
    $c->stash->{nick} = $c->req->param('nick') || 'nekokak';
    $c->stash->{name} = 'コバヤシアツシ';
    if ($args->{p} eq 'do_redirect') {
        $c->redirect('/redirect_done');
    } else {
        $c->stash->{args} = $args->{p};
    }

    $c->foo->call; # call plugin method;

    if ( $c->mobile->is_non_mobile ) {
        $c->stash->{agent} = 'pc';
    } else {
        if ($c->mobile->is_ezweb) {
            $c->stash->{agent} = 'ez';
        }
    }

    if ($c->req->is_post_request) {
        $c->stash->{method} = 'post';
        $c->fillin_fdat({name => 'nekokak'});
        my $validator = $c->validator('foo')->check;
        if ($validator->has_error) {
            $c->stash->{validator} = $validator;
            return;
        }
    } else {
        $c->stash->{method} = 'get';
    }
}

sub do_mobile {
    my ($class, $c, $args) = @_;
    $c->stash->{nick} = $c->req->param('nick') || 'nekokak';
    $c->stash->{name} = 'コバヤシアツシ';
    if ($args->{p} eq 'do_redirect') {
        $c->redirect('/redirect_done');
    } else {
        $c->stash->{args} = $args->{p};
    }

    warn $c->req->param('foo');
    warn Encode::is_utf8($c->req->param('foo'));

    $c->foo->call; # call plugin method;

    if ( $c->mobile->is_non_mobile ) {
        $c->stash->{agent} = 'pc';
    } else {
        if ($c->mobile->is_ezweb) {
            $c->stash->{agent} = 'ez';
        }
    }

    $c->stash->{method} = 'get';
}

sub do_moge : auth('Null') {
}

sub do_json {
    my ($class, $c) = @_;
    $c->stash->{json} = +{name => 'nekokak'};
    $c->view('JSON');
}

1;

