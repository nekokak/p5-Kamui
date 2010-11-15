package Kamui::Web;
use strict;
use warnings;
use Plack::Loader;

sub port { 5000 }
sub host { 0 }
sub server { 'Starlet' };

sub run {
    my $class = shift;
    my $app   = shift or die 'missing $app';

    Plack::Loader->load(
        $class->server,
        port => $class->port,
        host => $class->host,
        max_workers => 2,
        @_
    )->run($app);
}

1;

