package Kamui::Web::Controller;
use Kamui;
use UNIVERSAL::require;

sub dispatch {
    my ($class, $context) = @_;

    my $controller = $context->dispatch_rule->{controller};
    $controller->use or return $context->handle_404;
    my $method = $context->dispatch_rule->{action} or return $context->handle_404;

    if ($controller->can($method)) {
        my $code;
        eval {
            $code = $controller->$method($context, $context->dispatch_rule->{args});
        };
        if ($@) { return $context->handle_500 }
        if ($context->is_redirect) {
            return $code;
        }
        return $context->render;
    } else {
        return $context->handle_404;
    }
}

1;

