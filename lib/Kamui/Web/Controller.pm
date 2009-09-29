package Kamui::Web::Controller;
use Kamui;
use UNIVERSAL::require;

sub dispatch {
    my ($class, $context) = @_;

    my $controller = $context->dispatch_rule->{controller};
    $controller->use or return $context->handle_404;
    my $action = $context->dispatch_rule->{action} or return $context->handle_404;
    my $method = 'dispatch_'.$action;

    if ($controller->can($method)) {
        my $code;
        eval {
            $code = $controller->$method($context, $context->dispatch_rule->{args});
        };
        return $context->handle_500 if $@;
        return $code if $context->is_finished;
        return $context->render;
    } else {
        return $context->handle_404;
    }
}

1;

