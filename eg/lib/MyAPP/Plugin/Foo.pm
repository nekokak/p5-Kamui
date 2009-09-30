package MyAPP::Plugin::Foo;
use base 'Kamui::Plugin';

sub register_method {
    +{
        foo => sub {
            my $c = shift;
            $c->stash->{plugin_foo} = 'call foo';
        },
    };
}

1;

__END__
sub foo {
    my ($self, $c) = @_;
    $c->stash->{plugin_foo} = 'call foo';
}

1;

__END__


$c->plugin('session')->hoo;
