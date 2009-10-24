package Kamui::Plugin::Mobile::EmojiFilter;
use Kamui;
use base 'Kamui::Plugin';

sub register_method {
    +{
        mobile_emoji_filter => sub {
            my $c = shift;
            Kamui::Plugin::Mobile::EmojiFilter::Backend->new($c);
        },
    };
}

package Kamui::Plugin::Mobile::EmojiFilter::Backend;
use Kamui;
use Scalar::Util ();

sub new {
    my ($class, $c) = @_;
    bless {c => $c}, $class;
}

sub c { $_[0]->{c} }

sub finalize {
    my ($self, $res) = @_;

    if ( $res && $res->status == 200
        && $res->content_type =~ /html/
        && not( Scalar::Util::blessed( $res->body ) )
        && $res->body )
    {
        (my $body = $res->body) =~ s{ \{ (?:emoji|u): ([0-9A-F]{4}) \} }{ pack('U*', hex $1) }geixms;
        $res->body($body);
    }
}

1;

