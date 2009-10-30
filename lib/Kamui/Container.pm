package Kamui::Container;
use Kamui;
use base 'Class::Singleton';
use Exporter::AutoClean;
use UNIVERSAL::require;
use String::CamelCase qw/camelize/;
use Path::Class qw/file dir/;

my $_register_namespace = +{};

sub import {
    my ($class, @opts) = @_;
    my $caller = caller;

    if (scalar(@opts) == 1 and ($opts[0]||'') =~ /^-base$/i) {
        strict->import;
        warnings->import;
        utf8->import;

        {
            no strict 'refs';
            push @{"${caller}::ISA"}, $class;
        }

        my $register = $class->can('register');
        my $register_namespace = $class->can('register_namespace');
        Exporter::AutoClean->export(
            $caller,
            register => sub { $register->($caller, @_) },
            register_namespace => sub { $register_namespace->($caller, @_) },
        );
        return;
    }
    elsif(@opts) {
        $class->_export_functions($caller => @opts);
    }

    $class->_export_container($caller);
    $class->initialize;
}

sub initialize {
    my $class = shift;

    $class->register(
        home => sub {
            return $ENV{KAMUI_HOME} if $ENV{KAMUI_HOME};
            my $class = shift;

            $class = ref $class || $class;
            (my $file = "${class}.pm") =~ s!::!/!g;
            if (my $path = $INC{$file}) {
                $path =~ s/$file$//;
                $path = dir($path);
                if (-d $path) {
                    $path = $path->absolute;
                    while ($path->dir_list(-1) =~ /^b?lib$/) {
                        $path = $path->parent;
                    }
                    return $path;
                }
            }
            die 'Cannot detect home directory, please set it manually: $ENV{KAMUI_HOME}';
        },
    );

    $class->register(
        conf => sub {
            my $class = shift;
            my $home = $class->get('home');

            my $conf = {};
            for my $fn (qw/config.pl config_local.pl/) {
                my $file = $home->file($fn);
                if (-e $file) {
                    my $c = require $file;
                    die 'config should return HASHREF'
                        unless ref($c) and ref($c) eq 'HASH';
                    $conf = { %$conf, %$c };
                }
            }
            $conf;
        },
    );
}

sub _export_functions {
    my ($class, $caller, @export_names) = @_;

    for my $name (@export_names) {

        if ($caller->can($name)) { die qq{can't export $name for $caller. $name already defined in $caller.} }
        my $code = $_register_namespace->{$name} || sub {
            my $target = shift;
            my $container_name = join '::', $class->base_name, camelize($name), camelize($target);
            return $target ? $class->get($container_name) : $class;
        };

        {
            no strict 'refs';
            *{"${caller}::${name}"} = $code;
        }
    }
}

sub _export_container {
    my ($class, $caller) = @_;

    if ($caller->can('container')) { die qq{can't export container for $caller. container already defined in $caller.} }
    my $code = sub {
        my $target = shift;
        return $target ? $class->get($target) : $class;
    };
    {
        no strict 'refs';
        *{"${caller}::container"} = $code;
    }
}

sub register {
    my ($self, $class, @init_opt) = @_;
    $self = $self->instance unless ref $self;

    my $initializer;
    if (@init_opt == 1 and ref($init_opt[0]) eq 'CODE') {
        $initializer = $init_opt[0];
    }
    else {
        $initializer = sub {
            $self->load_class($class);
            $class->new(@init_opt);
        };
    }

    $self->{_registered_classes}->{$class} = $initializer;
}

sub register_namespace {
    my ($self, $method, $pkg) = @_;
    $self = $self->instance unless ref $self;
    my $class = ref $self;

    $pkg = camelize($pkg);
    my $code = sub {
        my $target = shift;
        my $container_name = join '::', $pkg, camelize($target);
        $self->load_class($container_name);
        return $target ? $class->get($container_name) : $class;
    };

    $_register_namespace->{$method} = $code;
}

sub get {
    my ($self, $class) = @_;
    $self = $self->instance unless ref $self;

    my $obj = $self->{_inflated_classes}->{$class} ||= do {
        my $initializer = $self->{_registered_classes}->{$class};
        $initializer ? $initializer->($self) : ();
    };

    return $obj if $obj;

    $self->load_class($class);
    $obj = $self->{_inflated_classes}->{$class} = $class->new;
    $obj;
}

1;

