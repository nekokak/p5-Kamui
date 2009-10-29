package Mock::Api::Form::Foo;
use Kamui;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub say { 'foo' }

1;

