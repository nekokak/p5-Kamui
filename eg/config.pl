use Kamui;
use MyAPP::Container;
use Path::Class;
use HTML::Entities;
use Encode;
use URI::Escape;

my $home = container('home');

return +{
    view => {
        tt   => +{
            path    => $home->file('assets/tmpl')->stringify,
            options => '',
            filters => +{
                html_unescape => sub {
                    HTML::Entities::decode_entities(shift);
                },
                uri => sub{
                    Encode::is_utf8( $_[0] )
                        ? URI::Escape::uri_escape_utf8($_[0])
                        : URI::Escape::uri_escape($_[0]);
                },
                sjis => sub {
                    Encode::encode('sjis', $_[0])
                },
            },
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

