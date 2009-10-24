package Kamui::Plugin::Mobile::CSSFilter;
use Kamui;
use base 'Kamui::Plugin';

sub register_method {
    +{
        mobile_css_filter => sub {
            my $c = shift;
            Kamui::Plugin::Mobile::CSSFilter::Backend->new($c);
        },
    };
}

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
        my $inliner = Kamui::Plugin::Mobile::CSSFilter::MobileJpCSS->new(
            base_dir => context->config->project_root . '/assets/htdocs',
            agent    => ( $self->c->mobile || '' ),
        );
        $res->body( $inliner->apply($body) );
    }
}

package Kamui::Plugin::Mobile::CSSFilter::MobileJpCSS;
use Kamui;
#use base 'HTML::MobileJpCSS';

# HTML::MobileJpCSS がまだMobileAgentにしか対応していないので、
# 取りあえずアドホックにラップしておく
# 送ったパッチがあてられるのはいつだろうか
# ということでラップする準備

1;

