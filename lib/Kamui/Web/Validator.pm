package Kamui::Web::Validator;
use Kamui;

sub import {
    my ($class, $opt) = @_;

    if (($opt||'') =~ /^-base$/i) {
        my $caller = caller(0);
        {
            no strict 'refs';
            push @{"${caller}::ISA"}, $class;
        }

        for my $meth ( qw/new context/ ) {
            no strict 'refs';
            *{"$caller\::$meth"} = *{"$class\::$meth"};
        }

        goto &Kamui::import;
    }
}

sub new {
    my ($class, %args) = @_;
    bless {%args}, $class;
}

sub context { $_[0]->{context} }

1;

