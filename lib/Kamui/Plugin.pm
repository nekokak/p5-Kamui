package Kamui::Plugin;
use Kamui;

sub do_initialize { 0 }
sub do_finalize   { 0 }
sub register_method { die 'this method is abstract!' }

1;

