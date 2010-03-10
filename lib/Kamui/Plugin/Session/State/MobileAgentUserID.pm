package Kamui::Plugin::Session::State::MobileAgentUserID;
use Kamui;

sub new {
    my $class = shift;

    bless +{
        c => undef,
        @_
    }, $class,
}

sub get_session_id {
    my $self = shift;

    my $ma = $self->{c}->mobile;
    if ($ma->can('user_id') and (my $user_id = $ma->user_id)) {
        # TODO: ip check
        return $user_id;
    } else {
        return '';
    }
}

sub generate_session_id { $_[0]->get_session_id }
sub set_session_id {}
sub remove_session_id {}
sub finalize {}

1;

