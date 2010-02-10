package Kamui::Plugin::Session::State::Null;
use Kamui;
use base 'Kamui::Plugin::Session::State';

sub new {
    my $class = shift;
    bless +{ }, $class,
}

sub get_session_id {}
sub generate_session_id { $_[0]->get_session_id }
sub set_session_id {}
sub remove_session_id {}
sub finalize {}

1;

