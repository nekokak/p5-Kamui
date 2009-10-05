package MyAPP::Web::Authorizer::BasicAuth;
use Kamui;
use base 'Kamui::Web::Authorizer::BasicAuth';

my %users = (
    nekokak => 'test',
);
sub authorize {
    my ($class, $context) = @_;
    
    my ($user, $passwd) = $class->basic_auth($context);
    if ($user && $passwd && $users{$user} eq $passwd) {
        return;
    } else {
        return $class->show_error_page;
    }
}

1;

