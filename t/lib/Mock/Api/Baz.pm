package Mock::Api::Baz;
use Kamui;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub say { 'baz' }

1;

