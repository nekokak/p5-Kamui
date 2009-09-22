package Kamui;
use strict;
use warnings;
use utf8;

sub import {
    strict->import;
    warnings->import;
    utf8->import;

    my $pkg = caller(0);
    for my $meth ( qw/base_name/ ) {
        no strict 'refs';
        *{"$pkg\::$meth"} = \&$meth;
    }
}

sub base_name {
    my $class = shift;
    $class = ref $class unless $class;
    (my $base_name = $class) =~ s/(::.+)?$//g;
    $base_name;
}

1;

