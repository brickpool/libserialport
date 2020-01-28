#! perl

use ExtUtils::MakeMaker 6.64;

$Verbose = 0;

use Config qw(%Config);
my $bitint            = $Config{ptrsize} == 4 ? 32 : 64;
my $lib_archive_file  = 'libiio-win-deps.zip';
my $sp_root_dir       = 'libiio';
my $sp_lib_dir        = "$sp_root_dir/libs/$bitint";
my $sp_lib_file       = 'libserialport.dll.a';

WriteMakefile(
  MIN_PERL_VERSION    => 5.012004,
  NAME                => 'Sigrok::SerialPort',
  AUTHOR              => 'J. Schneider',
  VERSION_FROM        => 'lib/Sigrok/SerialPort.pm',
  ABSTRACT_FROM       => 'lib/Sigrok/SerialPort.pm',
  CONFIGURE_REQUIRES  => {
    'ExtUtils::MakeMaker' => 6.64,
  },
  BUILD_REQUIRES      => {
    'ExtUtils::Install'   => 1.54,
    'ExtUtils::Command'   => 1.17,
    'ExtUtils::Manifest'  => 1.58,
  },
  PREREQ_PM           => {
    'strict'                    => 1.04,
    'warnings'                  => 1.09,
    'Carp'                      => 1.17,
    'English'                   => 1.04,
    'Errno'                     => 1.11,
    'Exporter'                  => 5.6401,
#    'Moose'                     => 2.0007,
#    'MooseX::Params::Validate'  => 0.18,
    'Moo'                       => 2.003004,
    'Type::Tiny'                => 1.002001,
    'Function-Parameters'       => 2001003,
    'XSLoader'                  => 0.10,
  },
  TEST_REQUIRES       => {
    'Test::More'      => 0.95,
  },
  LICENSE           => 'lgpl_3_0',
  LIBS              => ["-l$sp_lib_dir/$sp_lib_file"],
  INC               => "-I./$sp_root_dir/include",
  MYEXTLIB          => "$sp_lib_dir/$sp_lib_file",
  test              => {TESTS => 't/*.t t/*/*.t'}
);

sub MY::postamble {
"
\$(MYEXTLIB): $sp_root_dir/Makefile
\tcd $sp_root_dir && \$(MAKE) \$(PASSTHRU)
";
}
