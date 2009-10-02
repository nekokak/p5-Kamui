package Mock::Web::Validator::Foo;
use Kamui::Web::Validator -base;

sub add {
    my $self = shift;
    $self->{engine}->check(
        name => [qw/NOT_NULL/],
    );
}

1;

