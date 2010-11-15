package MyAPP::Web::Handler;
use Kamui;
use base 'Kamui::Web::Handler';

use MyAPP::Web::Context;
sub context    {'MyAPP::Web::Context'}

use MyAPP::Web::Dispatcher;
sub dispatcher {'MyAPP::Web::Dispatcher'}

sub view       {'Kamui::View::TT'}
sub plugins    {['Encode']}

use MyAPP::Container -no_export;
sub container  { MyAPP::Container->instance }


1;

