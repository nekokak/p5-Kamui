package Kamui::Plugin::Session::Store::Memory;
use Kamui;
use base 'Kamui::Plugin::Session::Store';

my %session = ();

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub get_session_data {
    my ($self, $key) = @_;

    if (my $session = $session{$key}) {
        return $session;
    }
}

sub set_session_data {
    my ($self, $key, $value) = @_;
    $session{$key} = $value;
}

sub remove_session_data {
    my ($self, $key) = @_;
    delete $session{$key};
}

1;

