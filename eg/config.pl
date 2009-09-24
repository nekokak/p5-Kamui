use MyAPP::Container;
use Path::Class;

my $home = container('home');

return +{
    tmpl => {
        path    => $home->file('assets/tmpl')->stringify,
        options => '',
    },
};
