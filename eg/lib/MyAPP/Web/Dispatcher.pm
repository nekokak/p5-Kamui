package MyAPP::Web::Dispatcher;
use Kamui::Web::Dispatcher;

on '/' => run {
    return 'Root', 'index', FALSE, +{};
};

on '/json' => run {
    return 'Root', 'json', FALSE, +{ };
};

on '/(.+)' => run {
    return 'Root', 'index', FALSE, +{ p => $1 };
};

1;

