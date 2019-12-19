#!/bin/env perl

use ExtUtils::MakeMaker;

$Verbose = 0;

use Config qw(%Config);
my $bitint            = $Config{use64bitint} ? 64 : 32;
my $lib_archive_file  = 'libiio-win-deps.zip';
my $sp_root_dir       = 'libiio';
my $sp_lib_dir        = "$sp_root_dir/libs/$bitint";
my $sp_lib_file       = 'libserialport.dll.a';

WriteMakefile(
  MIN_PERL_VERSION    => 5.016003,
  NAME                => 'Sigrok::SerialPort',
  AUTHOR              => 'J. Schneider',
  VERSION_FROM        => 'lib/Sigrok/SerialPort.pm',
  ABSTRACT_FROM       => 'lib/Sigrok/SerialPort.pm',
  CONFIGURE_REQUIRES  => {
    'ExtUtils::MakeMaker' => 6.84,
  },
  BUILD_REQUIRES      => {
    'ExtUtils::Install'   => 1.54,
    'ExtUtils::Command'   => 1.18,
    'ExtUtils::Manifest'  => 1.63,
    'LWP::Simple'         => 0,
  },
  PREREQ_PM           => {
    'strict'                    => 0,
    'warnings'                  => 0,
    'Carp'                      => 1.32,
    'English'                   => 0,
    'Errno'                     => 0,
    'Exporter'                  => 5.68,
    'Moose'                     => 2.1005,
    'MooseX::Params::Validate'  => 0.21,
    'XSLoader'                  => 0.15,
  },
  TEST_REQUIRES       => {
    'Test::More'      => 0,
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
