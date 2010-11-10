use Kamui;
use MyAPP::Container;
use Path::Class;

return +{
    view => {
        tt => +{
            path => container('home')->file('assets/tmpl')->stringify,
        },
    },
};

