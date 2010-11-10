use MyAPP::Web::Handler;
use Plack::Builder;

my $app = MyAPP::Web::Handler->new;
builder {
    enable 'Debug', panels => [ qw(Memory) ];
    $app->handler;
};


