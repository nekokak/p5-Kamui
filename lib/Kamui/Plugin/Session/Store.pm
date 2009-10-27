package Kamui::Plugin::Session::Store;
use Kamui;

sub get_session_data    { die 'this method is abstract !'}
sub set_session_data    { die 'this method is abstract !'}
sub remove_session_data { die 'this method is abstract !'}

1;

