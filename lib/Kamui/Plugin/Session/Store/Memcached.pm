package Kamui::Plugin::Session::Store::Memcached;
use Kamui;
use base 'Kamui::Plugin::Session::Store';
use Cache::Memcached::Fast;

sub new {
    my ($class, %option) = @_;

    my $expire = delete $option{expire_for} || 0;
    my $c      = delete $option{c};

    bless {
        expire_for => $expire,
        c          => $c,
        memd       => Cache::Memcached::Fast->new(\%option)
    }, $class;
}

sub memd { $_[0]->{memd} }

sub get_session_data {
    my ($self, $key) = @_;
    $self->memd->get($key);
}

sub set_session_data {
    my ($self, $key, $value) = @_;
    $self->memd->set($key => $value, $self->{expire_for});
}

sub remove_session_data {
    my ($self, $key) = @_;
    $self->memd->delete($key);
}

1;

