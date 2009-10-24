package Kamui::Plugin::Mobile::DoCoMoGUIDFilter;
use Kamui;
use base 'Kamui::Plugin';

sub register_method {
    +{
        docomo_guid_filter => sub {
            my $c = shift;
            Kamui::Plugin::Mobile::DoCoMoGUIDFilter::Backend->new($c);
        },
    };
}

package Kamui::Plugin::Mobile::DoCoMoGUIDFilter::Backend;
use Kamui;
use HTML::StickyQuery::DoCoMoGUID;
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
        && $self->c->mobile_attribute->is_docomo
        && $res->body )
    {
        my $body = $res->body;
        $res->body(
            sub {
                my $guid = HTML::StickyQuery::DoCoMoGUID->new;
                $guid->sticky(
                    scalarref => \$body,
                );
            }->()
        );
    }
}

1;

