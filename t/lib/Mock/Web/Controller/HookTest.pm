package Mock::Web::Controller::HookTest;
use Kamui::Web::Controller -base;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub {
        my ($class, $c) = @_;
        $c->stash->{before_dispatch_hook} = 'called';
    },
);

1;

