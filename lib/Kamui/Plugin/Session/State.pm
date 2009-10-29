package Kamui::Plugin::Session::State;
use Kamui;
use Digest::SHA1 ();
use Time::HiRes ();

sub get_session_id    { die 'this method is abstract !' }
sub set_session_id    { die 'this method is abstract !' }
sub remove_session_id { die 'this method is abstract !' }

sub generate_session_id {
    my ($self, $sid_length) = @_;

    my $unique = ( [] . rand() );
    substr( Digest::SHA1::sha1_hex( Time::HiRes::gettimeofday() . $unique ), 0, $sid_length )
}

1;

