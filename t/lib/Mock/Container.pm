package Mock::Container;
use Kamui::Container -base;

register 'foo' => sub {
    my $self = shift;
    $self->load_class('Mock::Foo');
    Mock::Foo->new;
};

1;

