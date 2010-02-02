use inc::Module::Install;

all_from 'lib/Kamui.pm';
license 'perl';

requires 'Plack::Request'            => 0.09;
requires 'Plack'                     => 0.9027;
requires 'UNIVERSAL::require';
requires 'Class::Singleton';
requires 'String::CamelCase';
requires 'Path::Class';
requires 'Encode';
requires 'File::Spec';
requires 'URI::Escape';
requires 'HTML::Entities';
requires 'Text::MicroTemplate::Extended';
requires 'HTML::FillInForm::Lite';
requires 'Class::Trigger';
requires 'Class::Data::Inheritable';
requires 'Template';
requires 'Template::Stash::EscapeHTML';

test_requires 'Test::Declare';

tests 't/*.t t/*/*.t t/*/*/*.t';
recursive_author_tests('xt');
install_script 'script/kamui.pl';
auto_include;
auto_install;
auto_set_repository;

WriteAll;
