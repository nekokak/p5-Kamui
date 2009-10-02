package MyAPP::Web::Handler;
use Kamui::Web::Handler;

use_container 'MyAPP::Container';
use_plugins [qw/+MyAPP::Plugin::Foo MobileAttribute/];
use_context 'MyAPP::Web::Context';
use_view 'Kamui::View::TT';
use_dispatcher 'MyAPP::Web::Dispatcher';

1;

