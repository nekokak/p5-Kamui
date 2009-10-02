use Kamui;
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
    validator_message => +{
        param => +{
            age => '年齢',
        },
        function => +{
            not_null => '[_1]が空です',
        },
        message => +{
            'foo.bar' => 'fooがbarですね',
        },
    },
};
