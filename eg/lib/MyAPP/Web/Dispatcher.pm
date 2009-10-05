package MyAPP::Web::Dispatcher;
use Kamui::Web::Dispatcher;

on '/' => run {
    return 'Root', 'index', FALSE, +{};
};

on '/json' => run {
    return 'Root', 'json', FALSE, +{ };
};

on '/moge' => run {
    return 'Root', 'moge', FALSE, +{};
};

on '/sub/' => run {
    return 'Root::Sub', 'index', FALSE, +{};
};

on '/foo/' => run {
    return 'Root::Foo', 'index', FALSE, +{};
};

on '/(.+)' => run {
    return 'Root', 'index', FALSE, +{ p => $1 };
};

1;

