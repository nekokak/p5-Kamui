package Mock::Plugin::Initialize;
use Kamui;
use base 'Kamui::Plugin';

sub do_initialize { 1 }
sub register_method {
    +{
        ini => sub {
            Mock::Ini->new;
        },
    };
}

package Mock::Ini;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub initialize {
    my ($self, $res) = @_;
    print 'call initialize hook';
}

1;

