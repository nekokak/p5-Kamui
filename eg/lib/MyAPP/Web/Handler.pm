package MyAPP::Web::Handler;
use Kamui::Web::Handler;

use_container 'MyAPP::Container';
#use_plugins [qw/+MyAPP::Plugin::Foo Mobile::Attribute Encode/];
use_plugins [qw/+MyAPP::Plugin::Foo Mobile::Agent/];
#use_plugins [qw/+MyAPP::Plugin::Foo Mobile::Attribute Mobile::Encode/];
use_context 'MyAPP::Web::Context';
use_view 'Kamui::View::TT';
use_dispatcher 'MyAPP::Web::Dispatcher';

1;

