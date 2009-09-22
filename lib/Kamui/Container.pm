package Kamui::Container;
use Kamui;
use base 'Class::Singleton';
use Exporter::AutoClean;
use UNIVERSAL::require;
use Carp;
use String::CamelCase qw/camelize/;

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

        my $r = $class->can('register');
        Exporter::AutoClean->export(
            $caller,
            register => sub { $r->($caller, @_) },
        );
    }
    elsif(@opts) {
        $class->_export_functions($caller => @opts);
    }

    $class->_export_container($caller);
}

sub _export_functions {
    my ($class, $caller, @export_names) = @_;

    for my $name (@export_names) {

        if ($caller->can($name)) { die qq{can't export $name for $caller. $name already defined in $caller.} }
        my $code = sub {
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

sub load_class {
    my ($class, $pkg) = @_;
    $pkg->require or Carp::croak $@;
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

__END__
package Your::Container;
use Kamui::Container -base;

register 'model' => sub {
}

package Your::Hoge;
use Your::Container;

sub run {
    container('model')->single('aiu',{});
    container('config')->{foo}->{bar};
}

package Your::Moge;
use Your::Container qw/api model config/;

sub run {
    api('amazon')->
    config('app')->
    model('db')->
    container('foo')
}

