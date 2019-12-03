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

__END__

=head1 NAME

Sigrok::SerialPort::Base - is a base class for all SerialPort objects

=head1 SYNOPSIS

  use Sigrok::SerialPort::Base;
  
  my $sp = Sigrok::SerialPort::Base->new;

=head1 DESCRIPTION

These package is a base class. All SerialPort objects are usually based on this
class. The base class has no attributes.

=head2 EXPORT

=over 12

=item C<new()>

The constructor C<new> will be called without attributes.

  my $list = new Sigrok::SerialPort::Base;

=item C<get_major_package_version()>

Return the major package version number.

  print Sigrok::SerialPort::Base::get_major_package_version();

=item C<get_minor_package_version()>

Return the minor package version number.

  print Sigrok::SerialPort::Base::get_minor_package_version();

=item C<get_micro_package_version()>

Return the micro package version number.

  print Sigrok::SerialPort::Base::get_micro_package_version();

=item C<get_package_version_string()>

The package version number string.

  print Sigrok::SerialPort::Base::get_package_version_string();

=item C<get_current_lib_version()>

Return the "current" library version number.

  print Sigrok::SerialPort::Base::get_current_lib_version();

=item C<get_revision_lib_version()>

Return the "revision" library version number.

  print Sigrok::SerialPort::Base::get_revision_lib_version();

=item C<get_age_lib_version()>

Return the "age" library version number.

  print Sigrok::SerialPort::Base::get_age_lib_version();

=item C<get_lib_version_string()>

Return the library version number string.

  print Sigrok::SerialPort::Base::get_lib_version_string();

=back

=head2 SUBTYPES

=over 12

=item C<sp_return>

Return values: C<SP_OK|SP_ERR_...> constants

=item C<sp_mode>

Port access modes: C<SP_MODE_...> constants

=item C<sp_event>

Port events: C<SP_EVENT_...> constants

=item C<sp_buffer>

Buffer selection: C<SP_BUF_...> constants

=item C<sp_parity>

Parity settings: C<SP_PARITY_...> constants

=item C<sp_rts>

RTS pin behaviour: C<SP_RTS_...> constants

=item C<sp_cts>

CTS pin behaviour: C<SP_CTS_...> constants

=item C<sp_dtr>

DTR pin behaviour: C<SP_DTR_...> constants

=item C<sp_dsr>

DSR pin behaviour: C<SP_DSR_...> constants

=item C<sp_xonxoff>

XON/XOFF flow control behaviour: C<SP_XONXOFF_...> constants

=item C<sp_flowcontrol>

Standard flow control combinations: C<SP_FLOWCONTROL_...> constants

=item C<sp_signal>

Input signals: C<SP_SIG_...> constants

=item C<sp_transport>

Transport types: C<SP_TRANSPORT_...> constants

=item C<sp_port>

A handle on an opaque structure representing a serial port. Valid values are
positive.

=item C<sp_port_config>

A handle on an opaque structure representing the configuration for a serial
port. Valid values are positive.

=item C<sp_event_set>

A handle on an opaque structure for events. Valid values are positive.

=item C<sp_baudrate>

Baud rate in bits per second: C<-1|50|75|110|134|150|200|300|600|1200|1800|2400|4800|9600|14400|19200|38400|57600|115200|128000|230400|256000|460800>

=item C<sp_databits>

Number of data bits C<5|6|7|8>, or C<-1> to retain the current setting.

=item C<sp_stopbits>

Number of stop bits C<1|2>, or C<-1> to retain the current setting.

=item C<unsigned_int>

The C<unsigned_int> is a data type specifier, that makes a variable only
represent natural numbers (positive numbers and zero).

=item C<size_t>

C<size_t> is used in the libserialport library to represent sizes and counts.

=back

=head1 SEE ALSO

Please see those websites for more information related to the library API.

=over 4

=item *

L<Sigrok|http://sigrok.org/wiki/Libserialport>

=item *

L<github|https://github.com/sigrokproject/libserialport>

=back

=head1 SOURCE

Source repository is at L<https://github.com/brickpool/libserialport>.

=head1 AUTHOR

J. Schneider L<https://github.com/brickpool>

=head1 COPYRIGHT AND LICENSE

=over 4

=item *

Copyright (C) 2019 J. Schneider L<https://github.com/brickpool>

=back

This library is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
