package Mock::Plugin::Finalize;
use Kamui;
use base 'Kamui::Plugin';

sub register_method {
    +{
        fin => sub {
            Mock::Fin->new;
        },
    };
}

package Mock::Fin;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub call { 'finalize' }
sub finalize {
    my ($self, $res) = @_;
    print 'call finalize hook';
}

1;

