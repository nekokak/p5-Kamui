package Kamui::Web::Controller;
use Kamui;
use base qw/Class::Data::Inheritable/;
use Class::Trigger qw/before_dispatch after_dispatch/;

__PACKAGE__->mk_classdata('authorizer');

sub import {
    my ($class, $opt) = @_;

    if (($opt||'') =~ /^-base$/i) {
        my $caller = caller(0);
        {
            no strict 'refs';
            push @{"${caller}::ISA"}, $class;
        }
        goto &Kamui::import;
    }
}

sub _load_auth_class {
    my ($class, $pkg) = @_;
    $pkg = 'Kamui::Web::Authorizer::'.$pkg unless $pkg =~ s/^\+//;
    $class->load_class($pkg);
    $pkg;
}

sub authorize {
    my ($class, $code, $context) = @_;

    my $dispatch_auth = $class->attr_cache($code);
    if ($dispatch_auth) {
        my $pkg = $class->_load_auth_class($dispatch_auth);
        return $pkg->authorize($context);
    }

    my $controller_auth = $class->authorizer;
    if ($controller_auth) {
        my $pkg = $class->_load_auth_class($controller_auth);
        return $pkg->authorize($context);
    }
    return;
}

my $cache = +{};
sub attr_cache {
    my ($class, $code, $attr) = @_;
    if ($attr) {
        (my $auth_pkg = $attr->[0]) =~ s/auth\('(.+)'\)/$1/;
        $cache->{$code} = $auth_pkg;
    } else {
        return $cache->{$code};
    }
}

sub MODIFY_CODE_ATTRIBUTES {
    my ($class, $code, @attrs) = @_;
    $class->attr_cache($code, \@attrs);
    return;
}

1;

