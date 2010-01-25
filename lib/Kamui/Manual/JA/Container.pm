=head1 NAME

Kamui::Manual::JA::Container - KamuiのContainerについて

=head1 DESCRIPTION

kamuiでは色々なビジネスロジックの処理をまとめたクラスをcontainerというところから
取り出して使うことをおすすめしています。

デフォルトのcontainerとしてはconfとhomeが存在します。

confは名前のとおりアプリケーション用の設定情報にアクセスし、
homeはアプリケーションが配置されているhomeディレクトリ情報にアクセスします。

Kamui::Containerではそれ以外にも様々なロジックを格納し
好きな場所でそのロジックを取り出すことができます。

=head1 Containerの使い方

Containerをつかうには

    package MyApp::Container;
    use Kamui::Container -base;
    1;

このようなクラスを定義します。
KamuiではContainerクラスは必ず定義する必要があります。

これだけでconf/homeは自動で定義されます。

=head2 ロジックをContainerに登録する

    package MyApp::Container;
    use Kamui::Container -base;
    
    register foo => sub {'foo'};
    1;

まずKamui::Containerをuseする時に引数として-baseを指定します。
-baseと指定することで、このクラスがContainerのベースクラスとなり、register関数がexportされます。

そして、このようにregisterという関数を使うことでContainerクラスにロジックを登録することができます。
register関数の第一引数にロジックにアクセスする名前を定義し、
第二引数にそのロジックのコンストラクタを定義します。
第二引数に定義しているのが、実際のロジックにアクセスするためのコンストラクタということに注意しくてください。

なので、

    package MyApp::Container;
    use Kamui::Container -base;
    use Foo;
    
    register foo => sub {
        Foo->new;
    };
    1;

多くの場合はこのようにオブジェクトのインスタンスを作るかと思います。

=head2 Containerに登録したロジックへのアクセス

定義したcontainer情報は

    package MyAPP::Demo;
    use MyAPP::Container;
    
    sub run {
        container('foo');
    }
    1;

このようにすればアクセスすることが可能です。

Kamui::Containerを使ってつくったMyAPP::Containerをuseすると、
自動でcontainerという関数がuseしたクラスにexportされます。

    container('foo')

と、初回呼び出した段階で登録されているコンストラクタが一度実行されます。
二度目以降のアクセスでは、初回に実行されたコンストラクタの情報がキャッシュされているので効率的です。

=head2 Containerからのビジネスロジックへの別のアクセス方法

Containerにビジネスロジックをどんどん登録することで、
自由に好きな場所からビジネスロジックにアクセスすることが可能ですが、
Kamui::Containerではわざわざregister関数を使ってロジックを登録しなくても
簡単にビジネスロジックにアクセスすることが可能です。

例えば、

    package MyAPP::Api::Foo;
    use strict;
    use warnings;
    sub new {
        my $class = shift;
        bless {}, $class;
    }
    sub foo {'foo'}
    1;

このようなビジネスロジックの処理をまとめたクラスがあるとします。
このクラスにアクセスするときにregister関数を使う場合

    package MyAPP::Container;
    use Kamui::Container -base;
    use MyAPP::Api::Foo;
    register api_foo => sub {
        MyAPP::Api::Foo->new;
    };
    1

このように書きます。
しかしいちいちregisterで登録するのが面倒なので別の方法を使います。

Kamui::Containerは

    package MyAPP::Demo;
    use MyAPP::Container qw/api/;
    
    sub run {
        api('Foo')->foo;
    }
    1;

このようにContainerクラスをuseす時に文字列を指定すると
指定した文字列の名前の関数がexportされます。

exportされた関数経由でビジネスロジックにアクセスします。


この例の場合、apiという文字列を指定しているので
apiという関数がexportされます。
exportされたapiという関数は引数で受け取った文字列を使って内部では
MyAPP::Api::Fooというクラスをuseし、newメソッド（コンストラクタ）を実行し
MyAPP::APi::Fooというクラスのインスタンスをキャッシュします。


今回の例ではapiという文字列を指定してapiという関数をexportしましたが、

    package MyAPP::Command::Foo;
    use strict;
    use warnings;
    sub new {
        my $class = shift;
        bless {}, $class;
    }
    sub foo {'foo'}
    1;

    package MyAPP::Demo;
    use MyAPP::Container qw/command/;
    
    sub run {
        command('Foo')->foo;
    }
    1;

とcommandという文字列を指定するとcommandという名前で関数がexportされ、
MyAPP::Command::*というクラスにアクセスすることが可能になります。

=cut

