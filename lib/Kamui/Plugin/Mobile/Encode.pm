package Kamui::Plugin::Mobile::Encode;
use Kamui;
use base 'Kamui::Plugin';

sub do_initialize { 1 }
sub do_finalize   { 1 }
sub register_method {
    +{
        mobile_encode => sub {
            my $c = shift;
            Kamui::Plugin::Mobile::Encode::Backend->new($c);
        },
    };
}

package Kamui::Plugin::Mobile::Encode::Backend;
use Kamui;
use Data::Visitor::Encode;
use Encode ();
use Encode::JP::Mobile ();
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
        my $body = $res->body;

        if (Encode::is_utf8( $body )) {
            $res->body( Encode::encode( $self->c->mobile->encoding, $body ) );

            my $content_type = $res->content_type || 'text/html';
            if ($content_type =~ m!^text/!) {
                my $charset = $self->c->mobile->can_display_utf8 ? 'UTF-8' : 'Shift_JIS';
                unless ($content_type =~ s/charset\s*=\s*[^\s]*;?/charset=$charset/ ) {
                    $content_type .= '; ' unless $content_type =~ /;\s*$/;
                    $content_type .= "charset=$charset";
                }
                if ( $content_type =~ m!^text/html!) {
                    if ( $self->c->mobile->is_docomo && $self->c->mobile->xhtml_compliant ) {
                        $content_type =~ s!text/html!application/xhtml+xml!;
                    }
                }
                $res->content_type( $content_type );
            }
        }
    }
}

1;

# HTTP::MobileAttribute依存かな
