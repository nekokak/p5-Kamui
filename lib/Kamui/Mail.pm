package Kamui::Mail;
use Kamui;
use MIME::Lite::TT::Japanese;
use File::Slurp;
use Template;
use Encode qw//;
use Template::Provider::Encoding;
 
sub new {
    my ($class, $tmpl_name, $args) = @_;

    my $params;

    $params->{conf} = delete $args->{conf};
    unless ($params->{conf}) {
        die "no conf error!";
    }

    $args->{LineWidth} ||= 0;
    $params->{from} = $args->{From};
    $params->{return_path} = $args->{'Return-Path'};

    $params->{mail} = MIME::Lite::TT::Japanese->new(
        %$args,
        %{$class->get_mail_template($params->{conf}, $tmpl_name, $args->{TmplParams})},
        TmplOptions => {
            ABSOLUTE    => 1,
            RELATIVE    => 1,
            ENCODING    => 'utf-8',
            FILTERS     => $params->{conf}->{view}->{tt}->{filters},
            COMPILE_DIR => '/tmp/' . $ENV{USER} . "/",
            LOAD_TEMPLATES => [ Template::Provider::Encoding->new ],
        },
        'X-User-Agent' => $ENV{HTTP_USER_AGENT} || 'unknown',
    );
    bless $params, $class;
}
 
sub attach {
    my ($self, $attach_data) = @_;
    $self->{mail}->attach( %$attach_data );
}
 
sub send {
    my $self = shift;

    if ($self->{conf}->{debug}) {
        my $output = $self->{mail}->as_string;
        Encode::from_to($output,'jis','utf8');
        print STDERR $output;
    } else {
        $self->{mail}->send(
            'sendmail',
            SetSender  => 1,
            FromSender => ($self->{return_path} ? $self->{return_path} : $self->{from}),
        );
    }

    $self->{send}=1;
}
 
sub get_mail_template {
    my ($class, $conf, $file_name, $args) = @_;
 
    my $src = read_file($conf->{view}->{tt}->{path}.'/mail/'.$file_name);
    if ($src =~ /\A([^\n]+)\n\n(.*)\Z/ms) {
        my $subject = $class->_get_subject($conf, $1, $args);
        my $body = $2;
        return {
            Subject  => $subject,
            Template => \$body,
        };
    } else {
        die "Invalid mail template. No subject!";
    }
}
 
sub _get_subject {
    my ($class, $conf, $subject, $args) = @_;
 
    my $tt = Template->new(
        ABSOLUTE    => 1,
        RELATIVE    => 1,
        ENCODING    => 'utf-8',
        FILTERS     => $conf->{view}->{tt}->{filters},
        COMPILE_DIR => '/tmp/' . $ENV{USER} . "/",
        LOAD_TEMPLATES => [ Template::Provider::Encoding->new ],
    );
    $tt->process(\$subject, $args ,\my $output) or die $@;
    $output;
}
 
sub DESTROY {
    my $self = shift;
    unless ($self->{send}) {
        my $class = ref $self;
        die "$class $self destroyed without send mail.";
    }
}
 
1;
 
=head1 NAME
 
Kamui::Mail - MIME::Lite::TT::Japanese with Kamui.
 
=head1 SYNOPSIS
 
    use Kamui::Mail;
    Kamui::Mail->new(
        'test.eml', => {
            From => 'nekokak@gmail.com',
            To   => 'nekokak@nekokak.org',
            TmplParams => +{
                subject_param => 'nekokak からだよ',
                body_param    => 'nekokak にだよ',
            },
            conf => container('conf'),
        }
    )->send;

