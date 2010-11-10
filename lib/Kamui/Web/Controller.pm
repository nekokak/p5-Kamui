package Kamui::Web::Controller;
use Kamui;
use Class::Trigger qw/before_dispatch after_dispatch/;

sub import {
    my ($class, $opt) = @_;

    if (($opt||'') =~ /^-base$/i) {
        my $caller = caller(0);
        {
            no strict 'refs';
            push @{"${caller}::ISA"}, $class;
            my $_auth='';
            *{"${caller}::_auth"} = sub {
                my ($class, $pkg) = @_;
                $_auth = $pkg if $pkg;
                $_auth;
            };
        }
        goto &Kamui::import;
    }
}

sub authorizer {
    my ($class, $pkg) = @_;
    $class->_auth($pkg);
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
        (my $auth_pkg = $attr->[0]) =~ s/Auth\('(.+)'\)/$1/;
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

