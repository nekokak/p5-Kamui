package Kamui::Web::Request;
use Kamui;
use base 'Plack::Request';

sub is_post_request { $_[0]->method eq 'POST' }
sub http_host { $_[0]->env->{HTTP_HOST} }

1;

