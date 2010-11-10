use MyAPP::Web;
use Plack::Builder;

my $app = MyAPP::Web->new;
builder {
    enable 'Debug', panels => [ qw(Memory) ];
    $app->handler;
};

