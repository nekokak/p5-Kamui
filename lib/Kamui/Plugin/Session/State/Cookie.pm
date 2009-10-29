package Kamui::Plugin::Session::State::Cookie;
use Kamui;
use base 'Kamui::Plugin::Session::State';

sub new {
    my $class = shift;

    bless +{
        c              => undef,
        cookie_name    => 'kamui_sid',
        cookie_domain  => '',
        cookie_path    => '',
        cookie_expires => '+1d',
        cookie_secure  => 0,
        update_cookie  => +{},
        @_
    }, $class,
}

sub get_session_id {
    my $self = shift;

    my $req = $self->{c}->req;

    if ( my $cookie = $req->cookies->{ $self->{cookie_name} } ) {
        my $sid = $cookie->value;
        return $sid if $sid;
    }

    return;
}
sub set_session_id {
    my ($self, $sid) = @_;
    $self->{update_cookie} = $self->make_cookie($sid);
}
sub remove_session_id {
    my ($self, $sid) = @_;
    $self->{update_cookie} = $self->make_cookie( $sid, { expires => 0 } );
}

sub make_cookie {
    my ($self, $sid, $attrs) = @_;

    my $cookie = {
        value   => $sid,
        expires => $self->{cookie_expires},
        secure  => $self->{cookie_secure},
        $self->{cookie_domain} ? (domain => $self->{cookie_domain}) : (),
        $self->{cookie_path}   ? (path   => $self->{cookie_path}) : (),
        %{ $attrs || {} },
    };
}

sub finalize {
    my ($self, $res) = @_;

    if (my $cookie = $self->{update_cookie}) {
        $res->cookies->{ $self->{cookie_name} } = $cookie;
    }
}

1;

