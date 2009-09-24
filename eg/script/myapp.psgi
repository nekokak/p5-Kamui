use MyAPP::Web::Handler;

my $app = MyAPP::Web::Handler->new;
$app->psgi_handler;

__END__
use MyAPP::Web::Handler;
use Plack::Builder;
use Plack::Middleware qw( Static );

my $app = MyAPP::Web::Handler->new;

builder {
#    enable Plack::Middleware::Static 'rules' => [
#        {
#            path =>  qr{\.(?:png|jpg|gif|css|txt)$},
#            root => './root/',
#        }
#    ];
    $app->psgi_handler;
};

__END__
use MyApp;
use Plack::Builder;
use Plack::Middleware qw( Static );

my $app = MyApp->new();

builder {
    enable Plack::Middleware::Static 'rules' => [
        {
            path =>  qr{\.(?:png|jpg|gif|css|txt)$},
            root => './root/',
        }
    ];
    $app->psgi_handler;
};

__END__

