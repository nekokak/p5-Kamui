use t::Utils;
use Test::More;
use Test::Exception;
use IO::Scalar;

BEGIN {
    eval "use Email::MIME::JP::Mobile";
    plan skip_all => 'needs Email::MIME::JP::Mobile for testing' if $@;
};

use Kamui::Mail;
use Mock::Container;

subtest 'no conf case' => sub {
    dies_ok(sub{
        Kamui::Mail->new(
            'test.eml', => {
                From => 'nekokak@gmail.com',
                To   => 'nekokak@gmail.com',
                TmplParams => +{
                    subject_param => 'nekokak からだよ',
                    body_param    => 'nekokak にだよ',
                },
            }
        );
    });
    done_testing;
};

subtest 'mail send' => sub {
  use Email::MIME::JP::Mobile;

    tie *STDERR, 'IO::Scalar', \my $out;

        Kamui::Mail->new(
            'test.eml', => {
                From => 'nekokak@gmail.com',
                To   => 'nekokak@gmail.com',
                TmplParams => +{
                    subject_param => 'nekokak からだよ',
                    body_param    => 'nekokak にだよ',
                },
                 container('conf'),
            }
        )->send;

    untie *STDERR;

    my $mail = Email::MIME::JP::Mobile->new($out);
    is $mail->subject, '[test] nekokak からだよ テストメールですよ';
    is $mail->body, "nekokak にだよあいうえお\n";

    done_testing;
};

subtest 'mail no send' => sub {

    dies_ok(
        sub {
            my $mail = Kamui::Mail->new(
                'test.eml', => {
                    From => 'nekokak@gmail.com',
                    To   => 'nekokak@gmail.com',
                    TmplParams => +{
                        subject_param => 'nekokak からだよ',
                        body_param    => 'nekokak にだよ',
                    },
                    conf => container('conf'),
                }
            );
            $mail = undef;
        }
    );

    done_testing;
};

done_testing;

