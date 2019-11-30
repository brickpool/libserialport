use strict;
use Test::More tests => 16;

use Sigrok::SerialPort qw( :version );

is SP_PACKAGE_VERSION_MAJOR, 0, "SP_PACKAGE_VERSION_MAJOR";
is SP_PACKAGE_VERSION_MINOR, 1, "SP_PACKAGE_VERSION_MINOR";
is SP_PACKAGE_VERSION_MICRO, 1, "SP_PACKAGE_VERSION_MICRO";
is SP_PACKAGE_VERSION_STRING, q{0.1.1}, "SP_PACKAGE_VERSION_STRING";

is SP_LIB_VERSION_CURRENT,   1, "SP_LIB_VERSION_CURRENT";
is SP_LIB_VERSION_REVISION,  0, "SP_LIB_VERSION_REVISION";
is SP_LIB_VERSION_AGE,       1, "SP_LIB_VERSION_AGE";
is SP_LIB_VERSION_STRING,    q{1:0:1}, "SP_LIB_VERSION_STRING";

is sp_get_major_package_version(),  SP_PACKAGE_VERSION_MAJOR,   'sp_get_major_package_version';
is sp_get_minor_package_version(),  SP_PACKAGE_VERSION_MINOR,   'sp_get_minor_package_version';
is sp_get_micro_package_version(),  SP_PACKAGE_VERSION_MICRO,   'sp_get_micro_package_version';
is sp_get_package_version_string(), SP_PACKAGE_VERSION_STRING,  'sp_get_package_version_string';

is sp_get_current_lib_version(),  SP_LIB_VERSION_CURRENT,   'sp_get_current_lib_version';
is sp_get_revision_lib_version(), SP_LIB_VERSION_REVISION,  'sp_get_revision_lib_version';
is sp_get_age_lib_version(),      SP_LIB_VERSION_AGE,       'sp_get_age_lib_version';
is sp_get_lib_version_string(),   SP_LIB_VERSION_STRING,    'sp_get_lib_version_string';

done_testing;
