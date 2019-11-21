use strict;
use Test::More tests => 8;

use Sigrok::SerialPort qw( :version );
use Sigrok::SerialPort::Base;

my $sp = Sigrok::SerialPort::Base->new();

is $sp->get_major_package_version(),  SP_PACKAGE_VERSION_MAJOR,   'get_major_package_version';
is $sp->get_minor_package_version(),  SP_PACKAGE_VERSION_MINOR,   'get_minor_package_version';
is $sp->get_micro_package_version(),  SP_PACKAGE_VERSION_MICRO,   'get_micro_package_version';
is $sp->get_package_version_string(), SP_PACKAGE_VERSION_STRING,  'get_package_version_string';

is $sp->get_current_lib_version(),  SP_LIB_VERSION_CURRENT,   'get_current_lib_version';
is $sp->get_revision_lib_version(), SP_LIB_VERSION_REVISION,  'get_revision_lib_version';
is $sp->get_age_lib_version(),      SP_LIB_VERSION_AGE,       'get_age_lib_version';
is $sp->get_lib_version_string(),   SP_LIB_VERSION_STRING,    'get_lib_version_string';

done_testing;
