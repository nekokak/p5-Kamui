#! /usr/bin/perl
use strict;
use warnings;
use File::Path qw/mkpath/;
use Getopt::Long;
use Pod::Usage;
use Text::MicroTemplate ':all';

our $module;
GetOptions(
    'help' => \my $help,
) or pod2usage(0);
pod2usage(1) if $help;

my $confsrc = <<'...';
-- lib/$path.pm
package [%= $module %];
1;
-- lib/$path/Web/Handler.pm
package [%= $module %]::Web::Handler;
use Kamui::Web::Handler;

use_container '[%= $module %]::Container';
use_context '[%= $module %]::Web::Context';
use_dispatcher '[%= $module %]::Web::Dispatcher';
use_plugins [qw/Encode/];
use_view 'Kamui::View::MT';

1;
-- lib/$path/Web/Dispatcher.pm
package [%= $module %]::Web::Dispatcher;
use Kamui::Web::Dispatcher;

on '/' => run {
    return 'Root', 'index', FALSE, +{};
};

1;
-- lib/$path/Web/Context.pm
package [%= $module %]::Web::Context;
use Kamui;
use base 'Kamui::Web::Context';
1;
-- lib/$path/Web/Controller/Root.pm
package [%= $module %]::Web::Controller::Root;
use Kamui::Web::Controller -base;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub {
        my ($class, $c) = @_;
    }
);

sub do_index {
    my ($class, $c, $args) = @_;
}

1;
-- lib/$path/Container.pm
package [%= $module %]::Container;
use Kamui::Container -base;

register foo => sub {
    my $self = shift;
};

1;
-- assets/tmpl/root/index.html
? extends 'base.html';
? block title => 'kamui page';
? block content => sub { 'hello, Kamui world!' };
-- assets/tmpl/base.html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title><? block title => 'Kamui' ?></title>
    <meta http-equiv="Content-Style-Type" content="text/css" />  
    <meta http-equiv="Content-Script-Type" content="text/javascript" />  
</head>
<body>
    <div id="Container">
        <div id="Header">
            <a href="/">Kamui Startup Page</a>
        </div>
        <div id="Content">
            <? block content => 'body here' ?>
        </div>
        <div id="Footer">
            Powered by Kamui
        </div>
    </div>
</body>
</html>
-- assets/script/$dist.psgi
use [%= $module %]::Web::Handler;
use [%= $module %]::Container;
use Plack::Builder;
my $app = [%= $module %]::Web::Handler->new;
$app->setup;

my $home = container('home');
builder {
   enable "Plack::Middleware::Static",
           path => qr{^/(images|js|css)/},
           root => $home->file('assets/htdocs')->stringify;

   $app->handler;
};
-- config.pl
use Kamui;
use [%= $module %]::Container;
use Path::Class;

my $home = container('home');

return +{
    view => {
        mt => +{
            path => $home->file('assets/tmpl')->stringify,
        },
    },
    datasource => +{
    },
    plugins => +{
    },
};
-- config_local.pl
use Kamui;

return +{
    datasource => +{
    },
}; 
...

&main;exit;

sub _mkpath {
    my $d = shift;
    print "mkdir $d\n";
    mkpath $d;
}

sub main {
    $module = shift @ARGV or pod2usage(0);
    $module =~ s!-!::!g;

    # $module = "Foo::Bar"
    # $dist   = "Foo-Bar"
    # $path   = "Foo/Bar"
    my @pkg  = split /::/, $module;
    my $dist = join "-", @pkg;
    my $path = join "/", @pkg;

    mkdir $dist or die $!;
    chdir $dist or die $!;
    _mkpath "lib/$path";
    _mkpath "lib/$path/Web/Controller";
    _mkpath "assets/htdocs/css/";
    _mkpath "assets/htdocs/img/";
    _mkpath "assets/tmpl/root/";
    _mkpath "assets/script/";
    _mkpath "t/";

    my $conf = _parse_conf($confsrc);
    while (my ($file, $tmpl) = each %$conf) {
        $file =~ s/(\$\w+)/$1/gee;
        my $code = Text::MicroTemplate->new(
            tag_start => '[%',
            tag_end   => '%]',
            line_start => '%',
            template => $tmpl,
        )->code;
        my $sub = eval "package main;our \$module; sub { Text::MicroTemplate::encoded_string(($code)->(\@_))}";
        die $@ if $@;

        my $res = $sub->()->as_string;

        print "writing $file\n";
        open my $fh, '>', $file or die "Can't open file($file):$!";
        print $fh $res;
        close $fh;
    }
}

sub _parse_conf {
    my $fname;
    my $res;
    for my $line (split /\n/, $confsrc) {
        if ($line =~ /^--\s+(.+)$/) {
            $fname = $1;
        } else {
            $fname or die "missing filename for first content";
            $res->{$fname} .= "$line\n";
        }
    }
    return $res;
}

__END__

=head1 SYNOPSIS

    % kamui.pl MyApp

=cut

