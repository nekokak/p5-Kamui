package Mock::Foo;
use Kamui;

sub new { bless {}, __PACKAGE__ }
sub say { 'foo' }

1;

