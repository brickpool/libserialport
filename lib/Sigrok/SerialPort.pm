package Sigrok::SerialPort;

use strict;
use warnings;

use Exporter;

our $VERSION = 0.0202;

our @ISA = qw(Exporter);

# This allows declaration	use Sigrok::SerialPort qw( :const :version );
our %EXPORT_TAGS = (
  'enum' => [ qw(
    sp_get_port_by_name
    sp_free_port
    sp_list_ports
    sp_copy_port
    sp_free_port_list
  ) ],

  'port' => [ qw(
    SP_MODE_READ
    SP_MODE_WRITE
    SP_MODE_READ_WRITE

    SP_TRANSPORT_NATIVE
    SP_TRANSPORT_USB
    SP_TRANSPORT_BLUETOOTH

    sp_open
    sp_close
    sp_get_port_name
    sp_get_port_description
    sp_get_port_transport
    sp_get_port_usb_bus_address
    sp_get_port_usb_vid_pid
    sp_get_port_usb_manufacturer
    sp_get_port_usb_product
    sp_get_port_usb_serial
    sp_get_port_bluetooth_address
    sp_get_port_handle
  ) ],

  'config' => [ qw(
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

    sp_new_config
    sp_free_config
    sp_get_config
    sp_set_config
    sp_set_baudrate
    sp_get_config_baudrate
    sp_set_config_baudrate
    sp_set_bits
    sp_get_config_bits
    sp_set_config_bits
    sp_set_parity
    sp_get_config_parity
    sp_set_config_parity
    sp_set_stopbits
    sp_get_config_stopbits
    sp_set_config_stopbits
    sp_set_rts
    sp_get_config_rts
    sp_set_config_rts
    sp_set_cts
    sp_get_config_cts
    sp_set_config_cts
    sp_set_dtr
    sp_get_config_dtr
    sp_set_config_dtr
    sp_set_dsr
    sp_get_config_dsr
    sp_set_config_dsr
    sp_set_xon_xoff
    sp_get_config_xon_xoff
    sp_set_config_xon_xoff
    sp_set_flowcontrol
    sp_set_config_flowcontrol
  ) ],

  'data' => [ qw(
    SP_BUF_INPUT
    SP_BUF_OUTPUT
    SP_BUF_BOTH

    sp_blocking_read
    sp_blocking_read_next
    sp_nonblocking_read
    sp_blocking_write
    sp_nonblocking_write
    sp_input_waiting
    sp_output_waiting
    sp_flush
    sp_drain
  ) ],

  'waiting' => [ qw(
    SP_EVENT_RX_READY
    SP_EVENT_TX_READY
    SP_EVENT_ERROR

    sp_new_event_set
    sp_add_port_events
    sp_wait
    sp_free_event_set
  ) ],

  'signal' => [ qw(
    SP_SIG_CTS
    SP_SIG_DSR
    SP_SIG_DCD
    SP_SIG_RI

    sp_get_signals
    sp_start_break
    sp_end_break
  ) ],

  'error' => [ qw(
    SP_OK
    SP_ERR_ARG
    SP_ERR_FAIL
    SP_ERR_MEM
    SP_ERR_SUPP

    sp_last_error_code
    sp_last_error_message
    sp_free_error_message
    sp_set_debug
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

    sp_get_major_package_version
    sp_get_minor_package_version
    sp_get_micro_package_version
    sp_get_package_version_string
    sp_get_current_lib_version
    sp_get_revision_lib_version
    sp_get_age_lib_version
    sp_get_lib_version_string
  ) ],

);
$EXPORT_TAGS{all} = [
  @{ $EXPORT_TAGS{enum}     },
  @{ $EXPORT_TAGS{port}     },
  @{ $EXPORT_TAGS{config}   },
  @{ $EXPORT_TAGS{data}     },
  @{ $EXPORT_TAGS{waiting}  },
  @{ $EXPORT_TAGS{signal}   },
  @{ $EXPORT_TAGS{error}    },
  @{ $EXPORT_TAGS{version}  },
];
$EXPORT_TAGS{const} = [
  grep /^SP_/, @{ $EXPORT_TAGS{all} }
];
our @EXPORT    = ();
our @EXPORT_OK = (
  @{ $EXPORT_TAGS{all} },
);

require XSLoader;
eval { XSLoader::load(__PACKAGE__, $VERSION); } ||
  die "Error loading XS components for " . __PACKAGE__ .
      " (have you installed libserialport? is it in your LD_LIBRARY_PATH?):\n$_";

1;

__END__

=head1 NAME

Sigrok::SerialPort::Backend - XS module providing an interface to the API of the
C library libserialport

=head1 SYNOPSIS

  use Sigrok::SerialPort ':all';
  
  my $port;
  sp_get_port_by_name("COM3", \$port);
  print sp_get_port_description($port);
  
  END {
    sp_free_port($port);
  }

=head1 DESCRIPTION

L<libserialport|http://sigrok.org/wiki/Libserialport> is a small,
well-documented C library for general-purpose serial port communication. This is
a perl wrapper for the library.

=head2 EXPORT

=head3 Port enumeration

=over 12

=item C<:enum>

Use C<:enum> statement to import the following subroutines, which are not
exported by default.

  use Sigrok::SerialPort ':enum';

=item C<sp_get_port_by_name>

Obtain a pointer to a new sp_port structure representing the named port.

  $ret = sp_get_port_by_name($portname, \$port);

=item C<sp_free_port>

Free a port structure obtained from L</sp_get_port_by_name> or
L</sp_copy_port>.

  sp_free_port($port);

=item C<sp_list_ports>

List the serial ports available on the system.

  $ret = sp_list_ports(\@ports);

=item C<sp_copy_port>

Make a new copy of an sp_port structure.

  $ret = sp_copy_port($ports[0], \$port);

=item C<sp_free_port_list>

Free a port list obtained from L</sp_list_ports>.

  sp_free_port_list(@ports);

=back

=head3 Port handling

=over 12

=item C<:port>

Use C<:port> statement to import the following constants and subroutines, which
are not exported by default.

  use Sigrok::SerialPort ':port';

=item C<# Port access modes>

Open port for read access.

  SP_MODE_READ = 1,

Open port for write access.

  SP_MODE_WRITE = 2,

Open port for read and write access.

  SP_MODE_READ_WRITE = 3

=item C<# Transport types>

Native platform serial port.

  SP_TRANSPORT_NATIVE,

USB serial port adapter.

  SP_TRANSPORT_USB,

Bluetooth serial port adapter.

  SP_TRANSPORT_BLUETOOTH

=item C<sp_open>

Open the specified serial port.

  $ret = sp_open($port, SP_MODE_READ);

=item C<sp_close>

Close the specified serial port.

  $ret = sp_close($port);

=item C<sp_get_port_name>

Get the name of a port.

  $str = sp_get_port_name($port);

=item C<sp_get_port_description>

Get a description for a port, to present to end user.

  $str = sp_get_port_description($port);
  print("Port description: $str\n") if $str;

=item C<sp_get_port_transport>

Get the transport type used by a port.

  $int = sp_get_port_transport($port);
  if ($int == SP_TRANSPORT_NATIVE) {
    print("Native platform serial port.\n");
  } elsif ($int == SP_TRANSPORT_USB) {
    print("USB serial port adapter.\n");
  } elsif ($int == SP_TRANSPORT_BLUETOOTH) {
    print("Bluetooth serial port adapter.\n");
  }

=item C<sp_get_port_usb_bus_address>

Get the USB bus number and address on bus of a USB serial adapter port.

  $ret = sp_get_port_usb_bus_address($port, \$usb_bus, \$usb_address);

=item C<sp_get_port_usb_vid_pid>

Get the USB Vendor ID and Product ID of a USB serial adapter port.

  $ret = sp_get_port_usb_vid_pid($port, \$usb_vid, \$usb_pid);

=item C<sp_get_port_usb_manufacturer>

Get the USB manufacturer string of a USB serial adapter port.

  $str = sp_get_port_usb_manufacturer($port);
  print("USB manufacturer: $str\n") if $str;

=item C<sp_get_port_usb_product>

Get the USB product string of a USB serial adapter port.

  $str = sp_get_port_usb_product($port);
  print("USB product: $str\n") if $str;

=item C<sp_get_port_usb_serial>

Get the USB serial number string of a USB serial adapter port.

  $str = sp_get_port_usb_serial($port);
  print("USB serial number: $str\n") if $str;

=item C<sp_get_port_bluetooth_address>

Get the MAC address of a Bluetooth serial adapter port.

  $str = sp_get_port_bluetooth_address($port);
  print("MAC address: $str\n") if $str;

=item C<sp_get_port_handle>

Get the operating system handle for a port.

  $ret = sp_get_port_handle($port, \$handle);

=back

=head3 Configuration

=over 12

=item C<:config>

Use C<:config> statement to import the following constants and subroutines,
which are not exported by default.

  use Sigrok::SerialPort ':config';

=item C<# Parity settings>

Special value to indicate setting should be left alone.

  SP_PARITY_INVALID = -1

No parity.

  SP_PARITY_NONE = 0

Odd parity.

  SP_PARITY_ODD = 1

Even parity.

  SP_PARITY_EVEN = 2

Mark parity.

  SP_PARITY_MARK = 3

Space parity.

  SP_PARITY_SPACE = 4

=item C<# RTS pin behaviour>

Special value to indicate setting should be left alone.

  SP_RTS_INVALID = -1

RTS off.

  SP_RTS_OFF = 0

RTS on.

  SP_RTS_ON = 1

RTS used for flow control.

  SP_RTS_FLOW_CONTROL = 2

=item C<# CTS pin behaviour>

Special value to indicate setting should be left alone.

  SP_CTS_INVALID = -1

CTS ignored.

  SP_CTS_IGNORE = 0

CTS used for flow control.

SP_CTS_FLOW_CONTROL  = 1

=item C<# DTR pin behaviour>

Special value to indicate setting should be left alone.

  SP_DTR_INVALID = -1

DTR off.

  SP_DTR_OFF = 0

DTR on.

  SP_DTR_ON = 1

DTR used for flow control.

  SP_DTR_FLOW_CONTROL = 2

=item C<# DSR pin behaviour>

Special value to indicate setting should be left alone.

  SP_DSR_INVALID = -1

DSR ignored.

  SP_DSR_IGNORE = 0

DSR used for flow control.

  SP_DSR_FLOW_CONTROL = 1

=item C<# XON/XOFF flow control behaviour>

Special value to indicate setting should be left alone.

  SP_XONXOFF_INVALID = -1

XON/XOFF disabled.

  SP_XONXOFF_DISABLED = 0

XON/XOFF enabled for input only.

  SP_XONXOFF_IN = 1

XON/XOFF enabled for output only.

  SP_XONXOFF_OUT = 2

XON/XOFF enabled for input and output.

  SP_XONXOFF_INOUT = 3

=item C<# Standard flow control combinations>

No flow control.

  SP_FLOWCONTROL_NONE = 0

Software flow control using XON/XOFF characters.

  SP_FLOWCONTROL_XONXOFF = 1

Hardware flow control using RTS/CTS signals.

  SP_FLOWCONTROL_RTSCTS = 2

Hardware flow control using DTR/DSR signals.

  SP_FLOWCONTROL_DTRDSR = 3

=item C<sp_new_config>

Allocate a port configuration structure.

  $ret = sp_new_config(\$config);

=item C<sp_free_config>

Free a port configuration structure.

  sp_free_config($config);

=item C<sp_get_config>

Get the current configuration of the specified serial port.

  $ret = sp_get_config($port, $config);

=item C<sp_set_config>

Set the configuration for the specified serial port.

  $ret = sp_set_config($port, $config);

=item C<sp_set_baudrate>

Set the baud rate for the specified serial port.

  $ret = sp_set_baudrate($port, 9600);

=item C<sp_get_config_baudrate>

Get the baud rate from a port configuration.

  $ret = sp_get_config_baudrate($config, \$baudrate);

=item C<sp_get_config_baudrate>

Set the baud rate in a port configuration.

  $ret = sp_set_config_baudrate($config, 9600);

=item C<sp_set_bits>

Set the data bits for the specified serial port.

  $ret = sp_set_bits($port, 8);

=item C<sp_get_config_bits>

Get the data bits from a port configuration.

  $ret = sp_get_config_bits($config, \$data_bits);

=item C<sp_set_config_bits>

Set the data bits in a port configuration.

  $ret = sp_set_config_bits($config, 8);

=item C<sp_set_parity>

Set the parity setting for the specified serial port.

  $ret = sp_set_parity($port, SP_PARITY_NONE);

=item C<sp_get_config_parity>

Get the parity setting from a port configuration.

  $ret = sp_get_config_parity($config, \$parity);

=item C<sp_set_config_parity>

Set the parity setting in a port configuration.

  $ret = sp_set_config_parity($config, SP_PARITY_EVEN);

=item C<sp_set_stopbits>

Set the stop bits for the specified serial port.

  $ret = sp_set_stopbits($port, 8);

=item C<sp_get_config_stopbits>

Get the stop bits from a port configuration.

  $ret = sp_get_config_stopbits($config, \$data_stopbits);

=item C<sp_set_config_stopbits>

Set the stop bits in a port configuration.

  $ret = sp_set_config_stopbits($config, 8);

=item C<sp_set_rts>

Set the RTS pin behaviour for the specified serial port.

  $ret = sp_set_rts($port, SP_RTS_OFF);

=item C<sp_get_config_rts>

Get the RTS pin behaviour from a port configuration.

  $ret = sp_get_config_rts($config, \$rts);

=item C<sp_set_config_rts>

Set the RTS pin behaviour in a port configuration.

  $ret = sp_set_config_rts($config, SP_RTS_ON);

=item C<sp_set_cts>

Set the CTS pin behaviour for the specified serial port.

  $ret = sp_set_cts($port, SP_CTS_IGNORE);

=item C<sp_get_config_cts>

Get the CTS pin behaviour from a port configuration.

  $ret = sp_get_config_cts($config, \$cts);

=item C<sp_set_config_cts>

Set the CTS pin behaviour in a port configuration.

  $ret = sp_set_config_cts($config, SP_CTS_FLOW_CONTROL);

=item C<sp_set_dtr>

Set the DTR pin behaviour for the specified serial port.

  $ret = sp_set_dtr($port, SP_DTR_OFF);

=item C<sp_get_config_dtr>

Get the DTR pin behaviour from a port configuration.

  $ret = sp_get_config_dtr($config, \$dtr);

=item C<sp_set_config_dtr>

Set the DTR pin behaviour in a port configuration.

  $ret = sp_get_config_dtr($config, SP_DTR_ON);

=item C<sp_set_dsr>

Set the DSR pin behaviour for the specified serial port.

  $ret = sp_set_dsr($port, SP_DSR_IGNORE);

=item C<sp_get_config_dsr>

Get the DSR pin behaviour from a port configuration.

  $ret = sp_get_config_dsr($config, \$dsr);

=item C<sp_set_config_dsr>

Set the DSR pin behaviour in a port configuration.

  $ret = sp_get_config_dsr($config, SP_DSR_FLOW_CONTROL);

=item C<sp_set_xon_xoff>

Set the XON/XOFF configuration for the specified serial port.

  $ret = sp_set_xon_xoff($port, SP_XONXOFF_DISABLED);

=item C<sp_get_config_xon_xoff>

Get the XON/XOFF configuration from a port configuration.

  $ret = sp_get_config_xon_xoff($config, \$xon_xoff);

=item C<sp_set_config_xon_xoff>

Set the XON/XOFF configuration in a port configuration.

  $ret = sp_set_config_xon_xoff($config, SP_XONXOFF_INOUT);

=item C<sp_set_config_flowcontrol>

Set the flow control type in a port configuration.

  $ret = sp_set_config_flowcontrol($port, SP_FLOWCONTROL_RTSCTS);

=item C<sp_set_flowcontrol>

Set the flow control type for the specified serial port.

  $ret = sp_set_flowcontrol($port, SP_FLOWCONTROL_NONE);

=back

=head3 Data handling

=over 12

=item C<:data>

Use C<:data> statement to import the following constants and subroutines, which
are not exported by default.

  use Sigrok::SerialPort ':data';

=item C<# Buffer selection>

Input buffer.

  SP_BUF_INPUT = 1

Output buffer.

  SP_BUF_OUTPUT = 2

Both buffers.

  SP_BUF_BOTH = 3

=item C<sp_blocking_read>

Read bytes from the specified serial port, blocking until complete.

  $ret = sp_blocking_read($port, \$buf, $count, $timeout_ms);

=item C<sp_blocking_read_next>

Read bytes from the specified serial port, returning as soon as any data is
available.

  $ret = sp_blocking_read_next($port, \$buf, $count, $timeout_ms);

=item C<sp_nonblocking_read>

Read bytes from the specified serial port, without blocking.

  $ret = sp_nonblocking_read($port, \$buf, $count);

=item C<sp_blocking_write>

Write bytes to the specified serial port, blocking until complete.

  $ret = sp_blocking_write($port, $buf, $count, $timeout_ms);

=item C<sp_nonblocking_write>

Write bytes to the specified serial port, without blocking.

  $ret = sp_nonblocking_write($port, $buf, $count);

=item C<sp_input_waiting>

Gets the number of bytes waiting in the input buffer.

  $ret = sp_input_waiting($port);

=item C<sp_output_waiting>

Gets the number of bytes waiting in the output buffer.

  $ret = sp_output_waiting($port);

=item C<sp_flush>

Flush serial port buffers. Data in the selected buffer(s) is discarded.

  $ret = sp_flush($port, SP_BUF_BOTH);

=item C<sp_drain>

Wait for buffered data to be transmitted.

  $ret = sp_drain($port);

=back

=head3 Waiting

=over 12

=item C<:waiting>

Use C<:waiting> statement to import the following constants and subroutines,
which are not exported by default.

  use Sigrok::SerialPort ':waiting';

=item C<# Port events>

Data received and ready to read.

  SP_EVENT_RX_READY = 1

Ready to transmit new data.

  SP_EVENT_TX_READY = 2

Error occurred.

  SP_EVENT_ERROR = 4

=item C<sp_new_event_set>

Allocate storage for a set of events.

  $ret = sp_new_event_set(\$event_set);

=item C<sp_add_port_events>

Add events to a struct sp_event_set for a given port.

  $ret = sp_add_port_events($event_set, $port, SP_EVENT_RX_READY);

=item C<sp_wait>

Wait for any of a set of events to occur.

  $ret = sp_wait($event_set, $timeout_ms);

=item C<sp_wait>

Free a structure allocated by L</sp_new_event_set>.

  $ret = sp_free_event_set($event_set, $timeout_ms);

=back

=head3 Signals

=over 12

=item C<:signal>

Use C<:signal> statement to import the following constants and subroutines,
which are not exported by default.

  use Sigrok::SerialPort ':signal';

=item C<# Input signals>

Clear to send.

  SP_SIG_CTS = 1

Data set ready.

  SP_SIG_DSR = 2

Data carrier detect.

  SP_SIG_DCD = 4

Ring indicator.

  SP_SIG_RI = 8

=item C<sp_get_signals>

Gets the status of the control signals for the specified port.

  $ret = sp_get_signals($port, \$signal_mask);

=item C<sp_start_break>

Put the port transmit line into the break state.

  $ret = sp_start_break($port);

=item C<sp_end_break>

Take the port transmit line out of the break state.

  $ret = sp_end_break($port);

=back

=head3 Errors

=over 12

=item C<:error>

Use C<:error> statement to import the following constants and subroutines, which
are not exported by default.

  use Sigrok::SerialPort ':error';

=item C<# Return values>

Operation completed successfully.

  SP_OK = 0

Invalid arguments were passed to the function.

  SP_ERR_ARG = -1

A system error occurred while executing the operation.

  SP_ERR_FAIL = -2

A memory allocation failed while executing the operation.

  SP_ERR_MEM = -3

The requested operation is not supported by this system or device.

  SP_ERR_SUPP = -4

=item C<sp_last_error_code>

Get the error code for a failed operation.

  $ret = sp_last_error_code();

=item C<sp_last_error_message>

Get the error message for a failed operation.

  $ret = sp_last_error_message();

=item C<sp_last_error_message>

Free an error message returned by L</sp_last_error_message>.

  sp_free_error_message();

=item C<sp_set_debug>

Set the handler function for library debugging messages.

  # enable debugging
  sp_set_debug(1);
  ...
  # disable debugging
  sp_set_debug(0);

=back

=head3 Versions

=over 12

=item C<:version>

Use C<:version> statement to import the following constants and subroutines,
which are not exported by default.

  use Sigrok::SerialPort ':version';

=item C<# Package version>

The libserialport package 'major' version number.

  SP_PACKAGE_VERSION_MAJOR = 0

The libserialport package 'minor' version number.

  SP_PACKAGE_VERSION_MINOR = 1

The libserialport package 'micro' version number.

  SP_PACKAGE_VERSION_MICRO = 1

The libserialport package version ("major.minor.micro") as string.

  SP_PACKAGE_VERSION_STRING = "0.1.1"

=item C<# Library/libtool version>

The libserialport libtool 'current' version number.

  SP_LIB_VERSION_CURRENT = 1

The libserialport libtool 'revision' version number.

  SP_LIB_VERSION_REVISION = 0

The libserialport libtool 'age' version number.

  SP_LIB_VERSION_AGE = 1

The libserialport libtool version ("current:revision:age") as string.

  SP_LIB_VERSION_STRING = "1:0:1"

=item C<sp_get_major_package_version>

Get the major libserialport package version number.

  $ret = sp_get_major_package_version();

=item C<sp_get_minor_package_version>

Get the minor libserialport package version number.

  $ret = sp_get_minor_package_version();

=item C<sp_get_micro_package_version>

Get the micro libserialport package version number.

  $ret = sp_get_micro_package_version();

=item C<sp_get_package_version_string>

Get the libserialport package version number as a string.

  $ret = sp_get_package_version_string();

=item C<sp_get_current_lib_version>

Get the "current" part of the libserialport library version number.

  $ret = sp_get_current_lib_version();

=item C<sp_get_revision_lib_version>

Get the "revision" part of the libserialport library version number.

  $ret = sp_get_revision_lib_version();

=item C<sp_get_age_lib_version>

Get the "age" part of the libserialport library version number.

  $ret = sp_get_age_lib_version();

=item C<sp_get_lib_version_string>

Get the libserialport library version number as a string.

  $ret = sp_get_lib_version_string();

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

Copyright (C) 2013, 2015 Martin Ling <martin-libserialport@earth.li>

=item *

Copyright (C) 2014 Uwe Hermann <uwe@hermann-uwe.de>

=item *

Copyright (C) 2014 Aurelien Jacobs <aurel@gnuage.org>

=back

This library is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
