package Kamui::Web::Controller;
use Kamui;
use Class::Trigger qw/before_dispatch after_dispatch/;

sub import {
    my ($class, $opt) = @_;

    if (($opt||'') =~ /^-base$/i) {
        my $caller = caller(0);
        {
            no strict 'refs';
            push @{"${caller}::ISA"}, $class;
        }
        goto &Kamui::import;
    }
}

1;

