package Kamui::Plugin::Session::State::MobileAttributeID;
use Kamui;
use base 'Kamui::Plugin::Session::State';

sub new {
    my $class = shift;
    my $c = shift;

    bless +{
        @_
    }, $class,
}

sub get_session_id {
    my $self = shift;

    my $req = $self->{req};

    return;
}
sub set_session_id {
    my ($self, $sid) = @_;
}
sub remove_session_id {
    my ($self, $sid) = @_;
}

sub finalize {
    my ($self, $res) = @_;

}

1;

