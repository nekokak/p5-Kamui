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

$conf->{plugins}->{session} = +{
    state => +{
        class  => 'Kamui::Plugin::Session::State::Cookie',
        option => +{},
    },
    store => +{
        class  => 'Kamui::Plugin::Session::Store::Memory',
        option => +{},
    },
};

$conf->{plugins}->{mobile}->{css_filter} = +{
    base_dir => 't/assets/',
};

$conf->{debug} = 1;

return $conf;

