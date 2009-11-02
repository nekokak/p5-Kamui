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
        engine  => Kamui::Plugin::FormValidatorLite::Backend::Base->new($self->c->req),
        context => $self->c,
    );

    $validator->{engine}->set_message_data($self->c->conf->{'validator_message'});

    return $validator;
}

package Kamui::Plugin::FormValidatorLite::Backend::Base;
use Kamui;
use base 'FormValidator::Lite';

sub get_error_message_from_param {
    my ($self, $target_param) = @_;

    my %dup_check;
    my @messages;
    for my $err (@{$self->{_error_ary}}) {
        my $param = $err->[0];
        my $func  = $err->[1];

        next if $target_param ne $param;
        next if exists $dup_check{"$param.$func"};
        push @messages, $self->get_error_message( $param, $func );
        $dup_check{"$param.$func"}++;
    }

    return @messages;
}

1;

