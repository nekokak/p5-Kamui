package MyAPP::Plugin::Foo;
use base 'Kamui::Plugin';

sub register_method {
    +{
        foo => sub {
            my $c = shift;
            MyAPP::Foo->new($c);
        },
    };
}

package MyAPP::Foo;
sub new {
    my ($class, $c) = @_;
    bless {c => $c}, $class;
}

sub c { $_[0]->{c} }
sub call {
    my $self = shift;
    $self->c->stash->{plugin_foo} = 'called';
}

1;

