package Kamui::Web::Controller;
use Kamui;

sub import {
    my $caller = caller(0);
    goto &Kamui::import;
}

1;

__END__

register_hook
call_hook

