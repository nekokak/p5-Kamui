package Mock::Web::Controller::HookTest;
use Kamui::Web::Controller;

register_hook(
    'before_dispatch' => sub {
        my $c = shift;
        $c->stash->{before_dispatch_hook} = 'called';
    },
);

1;

