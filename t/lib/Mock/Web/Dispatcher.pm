package Mock::Web::Dispatcher;
use Kamui::Web::Dispatcher;

on '/' => run {
    return 'Root', 'index', FALSE, +{};
};

on '/handler_base_test' => run {
    return 'Test', 'handler_base_test', FALSE, +{};
};

on '/query_test/' => run {
    return 'Test', 'query_test', FALSE, +{};
};

on '/(.+)' => run {
    return 'Root', 'index', FALSE, +{ p => $1 };
};

1;

