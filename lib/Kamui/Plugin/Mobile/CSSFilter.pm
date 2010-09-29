package Kamui::Plugin::Mobile::CSSFilter;
use Kamui;
use base 'Kamui::Plugin';

sub do_finalize { 1 }
sub register_method {
    +{
        mobile_css_filter => sub {
            my $c = shift;
            Kamui::Plugin::Mobile::CSSFilter::Backend->new($c);
        },
    };
}

=head2 plugins config

HTML::MobileJpCSSに渡す設定をconfigに書いてください

    $conf->{plugins}->{mobile}->{css_filter} = +{
        base_dir => 't/assets/',
    };

=cut

package Kamui::Plugin::Mobile::CSSFilter::Backend;
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
        my $body = $res->body;
        my $inliner = HTML::MobileJpCSS->new(
            agent    => ( $self->c->mobile || '' ),
            %{$self->c->conf->{plugins}->{mobile}->{css_filter}},
        );
        $res->body( $inliner->apply($body) );
    }
}

1;

