package Sigrok::SerialPort::Base;

use Moose;
use Moose::Util::TypeConstraints;

use Sigrok::SerialPort qw(
  :const

  sp_get_major_package_version
  sp_get_minor_package_version
  sp_get_micro_package_version
  sp_get_package_version_string
  sp_get_current_lib_version
  sp_get_revision_lib_version
  sp_get_age_lib_version
  sp_get_lib_version_string
);

##
#
# enum types (from libserialport)
#
##

subtype 'sp_return'
  => as 'Int',
  => where { $_ >= SP_ERR_SUPP && $_ <= SP_OK },
  => message {
    "Validation failed for 'sp_return' with value $_ " .
    "(did you use the 'SP_OK|SP_ERR_...' constants?)"
  };

subtype 'sp_mode'
  => as 'Int',
  => where { $_ >= SP_MODE_READ && $_ <= SP_MODE_READ_WRITE },
  => message {
    "Validation failed for 'sp_mode' with value $_ " .
    "(did you use the 'SP_MODE_...' constants?) "
  };

subtype 'sp_event'
  => as 'Int',
  => where { $_ > 0 && $_ <= SP_EVENT_RX_READY+SP_EVENT_TX_READY+SP_EVENT_ERROR },
  => message {
    "Validation failed for 'sp_event' with value $_ " .
    "(did you use the 'SP_EVENT_...' constants?)"
  };

subtype 'sp_buffer'
  => as 'Int',
  => where { $_ >= SP_BUF_INPUT && $_ <= SP_BUF_BOTH },
  => message {
    "Validation failed for 'sp_buffer' with value $_ " .
    "(did you use the 'SP_BUF_...' constants?)"
  };

subtype 'sp_parity'
  => as 'Int',
  => where { $_ == -1 || $_ >= SP_PARITY_INVALID && $_ <= SP_PARITY_SPACE },
  => message {
    "Validation failed for 'sp_parity' with value $_ " .
    "(did you use the 'SP_PARITY_...' constants?)"
  };

subtype 'sp_rts'
  => as 'Int',
  => where { $_ == -1 || $_ >= SP_RTS_INVALID && $_ <= SP_RTS_FLOW_CONTROL },
  => message {
    "Validation failed for 'sp_rts' with value $_ " .
    "(did you use the 'SP_RTS_...' constants?)"
  };

subtype 'sp_cts'
  => as 'Int',
  => where { $_ == -1 || $_ >= SP_CTS_INVALID && $_ <= SP_CTS_FLOW_CONTROL },
  => message {
    "Validation failed for 'sp_cts' with value $_ " .
    "(did you use the 'SP_CTS_...' constants?)"
  };

subtype 'sp_dtr'
  => as 'Int',
  => where { $_ == -1 || $_ >= SP_DTR_INVALID && $_ <= SP_DTR_FLOW_CONTROL },
  => message {
    "Validation failed for 'sp_dtr' with value $_ " .
    "(did you use the 'SP_DTR_...' constants?)"
  };

subtype 'sp_dsr'
  => as 'Int',
  => where { $_ == -1 || $_ >= SP_DSR_INVALID && $_ <= SP_DSR_FLOW_CONTROL },
  => message {
    "Validation failed for 'sp_dsr' with value $_ " .
    "(did you use the 'SP_DSR_...' constants?)"
  };

subtype 'sp_xonxoff'
  => as 'Int',
  => where { $_ == -1 || $_ >= SP_XONXOFF_INVALID && $_ <= SP_XONXOFF_INOUT },
  => message {
    "Validation failed for 'sp_xonxoff' with value $_ " .
    "(did you use the 'SP_XONXOFF_...' constants?)"
  };

subtype 'sp_flowcontrol'
  => as 'Int',
  => where { $_ >= SP_FLOWCONTROL_NONE && $_ <= SP_FLOWCONTROL_DTRDSR },
  => message {
    "Validation failed for 'sp_dsr' with value $_ " .
    "(did you use the 'SP_FLOWCONTROL_...' constants?)"
  };

subtype 'sp_signal'
  => as 'Int',
  => where { $_ >= 0 && $_ <= SP_SIG_CTS+SP_SIG_DSR+SP_SIG_DCD+SP_SIG_RI },
  => message {
    "Validation failed for 'sp_signal' with value $_ " .
    "(did you use the 'SP_SIG_...' constants?)"
  };

subtype 'sp_transport'
  => as 'Int',
  => where { $_ >= SP_TRANSPORT_NATIVE && $_ <= SP_TRANSPORT_BLUETOOTH },
  => message {
    "Validation failed for 'sp_transport' with value $_ " .
    "(did you use the 'SP_TRANSPORT_...' constants?)"
  };

##
#
# struct types (from libserialport)
#
##

subtype 'sp_port'
  => as 'Int',
  => where { $_ >= 0 };

subtype 'sp_port_config'
  => as 'Int',
  => where { $_ >= 0 };

subtype 'sp_event_set'
  => as 'Int',
  => where { $_ >= 0 };

##
#
# additional types
#
##

subtype 'sp_baudrate'
  => as 'Int',
  => where { /^(?:\-1|50|75|110|134|150|200|300|600|1200|1800|2400|4800|9600|14400|19200|38400|57600|115200|128000|230400|256000|460800)$/ };

subtype 'sp_databits'
  => as 'Int',
  => where { $_ == -1 || $_ >= 5 && $_ <= 8 };

subtype 'sp_stopbits'
  => as 'Int',
  => where { $_ == -1 || $_ == 1 || $_ == 2 };

subtype 'unsigned_int'
  => as 'Int',
  => where { $_ >= 0 };

subtype 'size_t'
  => as 'Int',
  => where { $_ >= 0 };

##
#
# Versions
#
##

sub get_major_package_version {
  return sp_get_major_package_version();
}

sub get_minor_package_version {
  return sp_get_minor_package_version();
}

sub get_micro_package_version {
  return sp_get_micro_package_version();
}

sub get_package_version_string {
  return sp_get_package_version_string();
}

sub get_current_lib_version {
  return sp_get_current_lib_version();
}

sub get_revision_lib_version {
  return sp_get_revision_lib_version();
}

sub get_age_lib_version {
  return sp_get_age_lib_version();
}

sub get_lib_version_string {
  return sp_get_lib_version_string();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
