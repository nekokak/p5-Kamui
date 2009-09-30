package MyAPP::Web::Handler;
use Kamui::Web::Handler;

use_container 'MyAPP::Container';
use_plugins [qw/+MyAPP::Plugin::Foo/];

#use_context 'MyAPP::Web::Context';
#view 'Kamui::View::TT';
#dispatcher 'MyAPP::Web::Dispatcher';

1;

