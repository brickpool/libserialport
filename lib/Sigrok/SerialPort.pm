package Sigrok::SerialPort;

use strict;
use warnings;

use Exporter;

our $VERSION = 0.02;

our @ISA = qw(Exporter);

# This allows declaration	use Sigrok::SerialPort qw( :const :version );
our %EXPORT_TAGS  = (
  'const' => [ qw(
    SP_OK
    SP_ERR_ARG
    SP_ERR_FAIL
    SP_ERR_MEM
    SP_ERR_SUPP
  
    SP_MODE_READ
    SP_MODE_WRITE
    SP_MODE_READ_WRITE
  
    SP_EVENT_RX_READY
    SP_EVENT_TX_READY
    SP_EVENT_ERROR
  
    SP_BUF_INPUT
    SP_BUF_OUTPUT
    SP_BUF_BOTH
  
    SP_PARITY_INVALID
    SP_PARITY_NONE
    SP_PARITY_ODD
    SP_PARITY_EVEN
    SP_PARITY_MARK
    SP_PARITY_SPACE
  
    SP_RTS_INVALID
    SP_RTS_OFF
    SP_RTS_ON
    SP_RTS_FLOW_CONTROL
  
    SP_CTS_INVALID
    SP_CTS_IGNORE
    SP_CTS_FLOW_CONTROL
  
    SP_DTR_INVALID
    SP_DTR_OFF
    SP_DTR_ON
    SP_DTR_FLOW_CONTROL
  
    SP_DSR_INVALID
    SP_DSR_IGNORE
    SP_DSR_FLOW_CONTROL
  
    SP_XONXOFF_INVALID
    SP_XONXOFF_DISABLED
    SP_XONXOFF_IN
    SP_XONXOFF_OUT
    SP_XONXOFF_INOUT
  
    SP_FLOWCONTROL_NONE
    SP_FLOWCONTROL_XONXOFF
    SP_FLOWCONTROL_RTSCTS
    SP_FLOWCONTROL_DTRDSR
  
    SP_SIG_CTS
    SP_SIG_DSR
    SP_SIG_DCD
    SP_SIG_RI

    SP_TRANSPORT_NATIVE
    SP_TRANSPORT_USB
    SP_TRANSPORT_BLUETOOTH
  ) ],

  'version' => [ qw(
    SP_PACKAGE_VERSION_MAJOR
    SP_PACKAGE_VERSION_MINOR
    SP_PACKAGE_VERSION_MICRO
    SP_PACKAGE_VERSION_STRING
  
    SP_LIB_VERSION_CURRENT
    SP_LIB_VERSION_REVISION
    SP_LIB_VERSION_AGE
    SP_LIB_VERSION_STRING
  ) ],
);
our @EXPORT    = ();
our @EXPORT_OK = (
  @{ $EXPORT_TAGS{const}    },
  @{ $EXPORT_TAGS{version}  },
);

require XSLoader;
eval { XSLoader::load(__PACKAGE__, $VERSION); } ||
  die "Error loading XS components for ".__PACKAGE__." (have you installed libserialport? is it in your LD_LIBRARY_PATH?):\n$_";

1;

__END__

=head1 NAME

Sigrok::SerialPort - module providing an interface to the API of the C library libserialport

=cut
