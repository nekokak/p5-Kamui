package Kamui::Plugin::Session::State;
use Kamui;

sub get_session_id    { die 'this method is abstract !' }
sub set_session_id    { die 'this method is abstract !' }
sub remove_session_id { die 'this method is abstract !' }

1;

