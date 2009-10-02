package MyAPP::Web::Validator::Foo;
use Kamui::Web::Validator -base;

sub check {
    my $self = shift;
    $self->{engine}->check(
        age => [qw/NOT_NULL/],
    );
}

1;

