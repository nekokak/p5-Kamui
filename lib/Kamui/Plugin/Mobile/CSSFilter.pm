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
        my $inliner = Kamui::Plugin::Mobile::CSSFilter::MobileJpCSS->new(
            agent    => ( $self->c->mobile || '' ),
            %{$self->c->conf->{plugins}->{mobile}->{css_filter}},
        );
        $res->body( $inliner->apply($body) );
    }
}

package Kamui::Plugin::Mobile::CSSFilter::MobileJpCSS;
use Kamui;
use base 'HTML::MobileJpCSS';

# HTML::MobileJpCSS がまだMobileAgentにしか対応していないので、
# 取りあえずアドホックにラップしておく

sub _init {
    my $self = shift;
    if ($self->{agent}) {
        $self->{agent} = HTTP::MobileAgent->new($self->{agent}) unless (ref $self->{agent}) =~ /^HTTP::Mobile(Agent|Attribute)/;
    }
    else {
        $self->{agent} = HTTP::MobileAgent->new();
    }
}

1;

