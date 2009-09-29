package t::Utils;
use strict;
use warnings;
use utf8;
use lib qw(./lib ./t/lib);
use Plack::Request;

sub import {
    my $caller = caller(0);

    strict->import;
    warnings->import;
    utf8->import;

    for my $func (qw/req/) {
        no strict 'refs'; ## no critic.
        *{$caller.'::'.$func} = \&$func;
    }
}

sub req {
    my $args = shift;

    open my $in, '<', \do { my $d };
    my $env = {
        'psgi.version'    => [ 1, 0 ],
        'psgi.input'      => $in,
        'psgi.errors'     => *STDERR,
        'psgi.url_scheme' => 'http',
        SERVER_PORT       => 80,
        REMOTE_ADDR       => '127.0.0.1',
        SERVER_PROTOCOL   => 'HTTP/1.1',
        SERVER_NAME       => 'example.com',
        %$args
    };
    Plack::Request->new($env);
}

1;

