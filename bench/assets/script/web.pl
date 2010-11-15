use MyAPP::Web::Handler;
use MyAPP::Web;
use Plack::Builder;

my $app = MyAPP::Web::Handler->new;
$app = builder {
    enable 'Debug', panels => [ qw(Memory) ];
    enable 'Plack::Middleware::StackTrace';
    $app->handler;
};

MyAPP::Web->run($app, max_workers => 5,);

