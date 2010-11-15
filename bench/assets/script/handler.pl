use MyAPP::Web::Handler;
use Plack::Builder;
use Plack::Loader;

my $app = MyAPP::Web::Handler->new;
$app = builder {
    enable 'Debug', panels => [ qw(Memory) ];
    $app->handler;
};

my $loader = Plack::Loader->load(
    'Starlet',
    port => 5000,
    host => '127.0.0.1',
    max_workers => 2,
);

$loader->run($app);

