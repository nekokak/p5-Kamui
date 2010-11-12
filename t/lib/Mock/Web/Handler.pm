package Mock::Web::Handler;
use Kamui;
use base 'Kamui::Web::Handler';

use Kamui::Web::Context;
sub context    {'Kamui::Web::Context'}

use Mock::Web::Dispatcher;
sub dispatcher {'Mock::Web::Dispatcher'}

sub view       {'Kamui::View::TT'}
sub plugins    {['Encode']}

use Mock::Container -no_export;
sub container  { Mock::Container->instance }

1;

