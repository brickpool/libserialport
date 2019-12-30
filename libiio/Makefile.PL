#! perl

use ExtUtils::MakeMaker 6.64;

$Verbose = 0;

use Config qw(%Config);
my $bitint            = $Config{ptrsize} == 4 ? 32 : 64;
my $lib_download_url  = 'http://swdownloads.analog.com/cse/build/libiio-win-deps.zip';
my $lib_archive_file  = 'libiio-win-deps.zip';
my $sp_include_dir    = 'include';
my $sp_lib_dir        = "libs/$bitint";
my $sp_file_h         = 'libserialport.h';
my $sp_file_a         = 'libserialport.dll.a';
my $sp_file_so        = 'libserialport-0.dll';

WriteMakefile (
  NAME    => 'Sigrok::SerialPort',
  VERSION => '0.1.1',
  BUILD_REQUIRES      => {
    'LWP::Simple'         => 6.00,
    'Archive::Zip'        => 1.30,
  },
  LICENSE => 'lgpl_3_0',
  SKIP    => [ qw(all static dynamic) ],
  clean   => { FILES => '*/ *.zip' },
  PM      => { "$sp_lib_dir/$sp_file_so" => "\$(INST_ARCHAUTODIR)/$sp_file_so"},
);

sub MY::top_targets {
"
UNCOMPRESS = \$(ABSPERLRUN) -MArchive::Zip -E\"my \$\$z = Archive::Zip->new; \$\$z->read(shift \@ARGV); \$\$z->extractMember(\$\$_) foreach \@ARGV;\"
DOWNLOAD = \$(INSTALLSCRIPT)/lwp-download
LIB_DOWNLOAD_URL = $lib_download_url
LIB_ARCHIVE_FILE = $lib_archive_file
SP_INCLUDE_DIR = $sp_include_dir
SP_LIB_DIR = $sp_lib_dir
SP_FILE_H = \$(SP_INCLUDE_DIR)/$sp_file_h
SP_FILE_A = \$(SP_LIB_DIR)/$sp_file_a
SP_FILE_SO = \$(SP_LIB_DIR)/$sp_file_so
SP_FILES = \$(SP_FILE_H) \$(SP_FILE_A) \$(SP_FILE_SO)

all :: pure_all

pure_all :: static pm_to_blib

static :: \$(LIB_ARCHIVE_FILE) \$(SP_FILES)

\$(LIB_ARCHIVE_FILE):
\t\$(DOWNLOAD) \$(LIB_DOWNLOAD_URL)

\$(SP_FILE_H): \$(LIB_ARCHIVE_FILE)
\t\$(NOECHO) \$(UNCOMPRESS) \$(LIB_ARCHIVE_FILE) \$(SP_FILE_H)
\t\$(NOECHO) \$(TOUCH) \$(SP_FILE_H)

\$(SP_FILE_A): \$(LIB_ARCHIVE_FILE)
\t\$(NOECHO) \$(UNCOMPRESS) \$(LIB_ARCHIVE_FILE) \$(SP_FILE_A)
\t\$(NOECHO) \$(TOUCH) \$(SP_FILE_A)

\$(SP_FILE_SO): \$(LIB_ARCHIVE_FILE)
\t\$(NOECHO) \$(UNCOMPRESS) \$(LIB_ARCHIVE_FILE) \$(SP_FILE_SO)
\t\$(NOECHO) \$(TOUCH) \$(SP_FILE_SO)
";
}
