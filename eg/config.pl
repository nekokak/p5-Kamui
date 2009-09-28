use MyAPP::Container;
use Path::Class;

my $home = container('home');

return +{
    view => {
        tt   => +{
            path    => $home->file('assets/tmpl')->stringify,
            options => '',
        },
        json => +{
            stash_key      => 'json',
            callback_param => 'callback',
        },
    },
};
