package MyAPP::Web::Handler;
use Kamui;
use base 'Kamui::Web::Handler';
use MyAPP::Container;

sub conf { container('conf') }

1;

