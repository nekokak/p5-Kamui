use Kamui;
use Mock::Container;
use Path::Class;

my $home = container('home');
my $conf = +{};

$conf->{view}->{tt} = +{
    path    => $home->file('assets/tmpl')->stringify,
    options => '',
};

$conf->{conf_test} = +{
    foo => 'bar',
    name => 'tpester',
};

$conf->{validator_message} = +{
    param => +{
        name => '名前',
    },
    function => +{
        not_null => '[_1]が空です',
    },
    message => +{
        'foo.bar' => 'fooがbarですね',
    },
};

use HTTP::Session::Store::OnMemory;
use HTTP::Session::State::Null;
$conf->{plugins}->{session} = +{
    store => HTTP::Session::Store::OnMemory->new(),
    state => HTTP::Session::State::Null->new(),
};

$conf->{plugins}->{mobile}->{css_filter} = +{
    base_dir => 't/assets/',
};

return $conf;

