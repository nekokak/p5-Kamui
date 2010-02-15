package Kamui::Plugin::FormValidatorLite;
use Kamui;
use base 'Kamui::Plugin';

sub register_method {
    +{
        validator => sub {
            my $c = shift;
            Kamui::Plugin::FormValidatorLite::Backend->new($c);
        },
    };
}

package Kamui::Plugin::FormValidatorLite::Backend;
use Kamui;
use String::CamelCase qw/camelize/;
use FormValidator::Lite;

sub new {
    my ($class, $c) = @_;

    my $self = bless {
        valid_classes => +{},
        context       => $c,
    }, $class;
}

sub c { $_[0]->{context} }
sub valid {
    my ($self, $valid_class_s) = @_;

    my $valid_class = $self->{valid_classes}->{$valid_class_s} ||= do {
        my $pkg = join '::', $self->c->app->base_name, 'Web', 'Validator', camelize($valid_class_s);
        $self->c->load_class($pkg);
        $pkg;
    };

    my $validator = $valid_class->new(
        engine  => FormValidator::Lite->new($self->c->req),
        context => $self->c,
    );

    $validator->{engine}->set_message_data($self->c->conf->{'validator_message'});

    return $validator;
}

1;

