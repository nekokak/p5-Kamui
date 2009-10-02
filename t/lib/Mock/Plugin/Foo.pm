package Mock::Plugin::Foo;
use Kamui;
use base 'Kamui::Plugin';

sub register_method {
    +{
        foo => sub {
            Mock::Foo->new;
        },
    };
}

package Mock::Foo;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub call { 'foo' }

1;

1;

