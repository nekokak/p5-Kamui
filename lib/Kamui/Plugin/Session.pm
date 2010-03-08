package Kamui::Plugin::Session;
use Kamui;
use base 'Kamui::Plugin';

sub do_finalize { 1 }
sub register_method {
    +{
        session => sub {
            my $c = shift;

            Kamui::Plugin::Session::Backend->new($c);
        },
    };
}

package Kamui::Plugin::Session::Backend;
use Kamui;

sub new {
    my ($class, $c) = @_;

    my $conf = $c->conf->{plugins}->{session} or die 'no session configuration!';

    my $self = bless {
        c               => $c,
        session_id      => '',
        session_data    => +{},
        session_updated => 0,
        sid_length      => 32,
        state           => undef,
        store           => undef,
        conf            => $conf,
    }, $class;

    $self->_setup;

    $self;
}

sub _setup {
    my $self = shift;

    $self->_setup_state;
    $self->_setup_store;
    $self->_load_session;
}

sub _setup_state {
    my $self = shift;

    my $pkg = $self->{conf}->{state}->{class};
    $self->{c}->app->load_class($pkg);
    $self->{state} = $pkg->new(
        c   => $self->{c},
        %{$self->{conf}->{state}->{option}}
    );
}

sub _setup_store {
    my $self = shift;

    my $pkg = $self->{conf}->{store}->{class};
    $self->{c}->app->load_class($pkg);
    $self->{store} = $pkg->new(%{$self->{conf}->{store}->{option}});
}

sub _load_session {
    my $self = shift;

    if (my $session_id = $self->_get_session_id) {
        $self->_set_session_id($session_id);
        $self->{session_data} = $self->_get_session_data($session_id);
    } else {
        $self->_initialize_session_data;
    }
}

sub get {
    my ($self, $key) = @_;
    my $data = $self->{session_data} or return;
    $data->{ $key };
}

sub set {
    my ($self, $key, $value) = @_;
    $self->{session_updated}=1;
    $self->{session_data}->{ $key } = $value;
}

sub remove {
    my ($self, $key) = @_;
    return unless $self->{session_data};
    $self->{session_updated}=1;
    delete $self->{session_data}->{ $key };
}

sub regenerate {
    my $self = shift;

    # ignore if session does not exists
    return unless $self->{session_id};

    my $session_data = $self->{session_data};
    $self->_remove_session_data($self->{session_id});

    $self->_initialize_session_data;
    $self->_set_session_data($self->{session_id} => $session_data);
    $self->{session_data} = $session_data;
}

sub finalize {
    my ($self, $res) = @_;

    if ($self->{session_updated} and my $sid = $self->{session_id}) {
        $self->{state}->finalize($res);
        $self->_set_session_data( $sid, $self->{session_data} );
    }
}

sub _initialize_session_data {
    my $self = shift;

    $self->_set_session_id(
        $self->_generate_session_id
    );
    $self->{session_data} = +{};
}

# State
sub _get_session_id { $_[0]->{state}->get_session_id }
sub _set_session_id {
    my ($self, $sid) = @_;
    $self->{session_id} = $sid;
    $self->{state}->set_session_id($sid);
}
sub _remove_session_id { $_[0]->{state}->remove_session_id($_[0]->{session_id}) }
sub _generate_session_id { $_[0]->{state}->generate_session_id($_[0]->{sid_length}) }

# Store
sub _get_session_data    { $_[0]->{store}->get_session_data($_[1])    }
sub _set_session_data    { $_[0]->{store}->set_session_data($_[1], $_[2])    }
sub _remove_session_data { $_[0]->{store}->remove_session_data($_[1]) }

1;

