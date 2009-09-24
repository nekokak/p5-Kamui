use strict;
use warnings;
use Test::Declare;
use lib './t/lib';
use Mock::Web::Dispatcher;
use HTTP::Request;

plan tests => blocks;

describe 'dispatcher tests' => run {
    test 'maping' => run {
        my $r = HTTP::Request->new(GET => '/');
        my $map = Mock::Web::Dispatcher->determine($r);
        is_deeply $map, {
            controller => 'Mock::Web::Controller::Root',
            action     => 'index',
            is_static  => 0,
            args       => {},
        };
    };
    test 'maping' => run {
        my $r = HTTP::Request->new(GET => '/foo');
        my $map = Mock::Web::Dispatcher->determine($r);
        is_deeply $map, {
            controller => 'Mock::Web::Controller::Root',
            action     => 'index',
            is_static  => 0,
            args       => { p => 'foo'},
        };
    };
};


