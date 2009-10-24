use t::Utils;
use Test::Declare;
use Kamui::Web::Context;
use Mock::Web::Handler;

plan tests => 1;

TODO: {
    local $TODO = "css filter is not finished";
    describe 'mobile css filter tests' => run {
        init {
            my $plugins = [qw/Mobile::Attribute Mobile::CSSFilter/];
            Kamui::Web::Context->load_plugins($plugins);
        };
        test 'css filter' => run { ok 1 };
    };
};

