package Kamui::Plugin;
use Kamui;

sub register_method { die 'this method is abstract!' }

1;

__END__
sub new {
    my ($class, $conf) = @_;

    my $self = bless {
        conf => $conf,
    }, $class;

    $self->initialize;
}

sub initialize { shift }
1;


__END__
pluginの実装でなやみちゅう

$c->fooのようにメソッドが呼べる形式と
$c->plugin('Foo')->fooと一段かます方式。。。

やっぱり$c->fooかなぁ
