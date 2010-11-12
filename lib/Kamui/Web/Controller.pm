package Kamui::Web::Controller;
use Kamui;

sub import {
    my ($class, $opt) = @_;

    if (($opt||'') =~ /^-base$/i) {
        my $caller = caller(0);

        {
            no strict 'refs';
            push @{"${caller}::ISA"}, $class;
        }

        {
            my $_auth='';
            my $code = sub {
                my ($class, $pkg) = @_;
                $_auth = $pkg if $pkg;
                $_auth;
            };
            no strict 'refs';
            *{"${caller}::_auth"} = $code;
        }

        {
            my $_trigger = +{
                before_dispatch => [],
                after_dispatch  => [],
            };
            my $code = sub {
                my ($class, $name, $code) = @_;
                push @{$_trigger->{$name}}, $code if $code;
                $_trigger->{$name};
            };
            no strict 'refs';
            *{"${caller}::_trigger"} = $code;
        }

        {
            my $_cache = +{};
            my $code = sub {
                my ($class, $code, $pkg) = @_;
                $_cache->{$code} = $pkg if $pkg;
                $_cache->{$code};
            };
            no strict 'refs';
            *{"${caller}::_cache"} = $code;
        }
        goto &Kamui::import;
    }
}

sub add_trigger {
    my ($class, $name, $code) = @_;
    $class->_trigger($name, $code);
    return;
}

sub call_trigger {
    my ($class, $name, $c, $args) = @_;

    for my $code (@{$class->_trigger($name)}) {
        my $res = $code->($class, $c, $args);
        return $res if ref($res) eq 'Kamui::Web::Response';
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

sub attr_cache {
    my ($class, $code, $attr) = @_;

    if ($attr) {
        (my $auth_pkg = $attr->[0]) =~ s/Auth\('(.+)'\)/$1/;
        $class->_cache($code, $auth_pkg);
    } else {
        $class->_cache($code);
    }
}

sub MODIFY_CODE_ATTRIBUTES {
    my ($class, $code, @attrs) = @_;
    $class->attr_cache($code, \@attrs);
    return;
}

1;

