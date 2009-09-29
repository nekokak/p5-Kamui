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

return $conf;

