package Sigrok::SerialPort::Backend;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# To declaration	use SerialPort::Backend ':all';
our @EXPORT     = ();
our @EXPORT_OK  = qw(
  sp_get_port_by_name
  sp_free_port
  sp_list_ports
  sp_copy_port
  sp_free_port_list

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

  sp_blocking_read
  sp_blocking_read_next
  sp_nonblocking_read
  sp_blocking_write
  sp_nonblocking_write
  sp_input_waiting
  sp_output_waiting
  sp_flush
  sp_drain

  sp_new_event_set
  sp_add_port_events
  sp_wait
  sp_free_event_set

  sp_get_signals
  sp_start_break
  sp_end_break

  sp_last_error_code
  sp_last_error_message
  sp_free_error_message
  sp_set_debug

  sp_get_major_package_version
  sp_get_minor_package_version
  sp_get_micro_package_version
  sp_get_package_version_string
  sp_get_current_lib_version
  sp_get_revision_lib_version
  sp_get_age_lib_version
  sp_get_lib_version_string
);
our %EXPORT_TAGS  = (
  'all' => \@EXPORT_OK,
);

use Sigrok::SerialPort;
our $VERSION = Sigrok::SerialPort::SP_PACKAGE_VERSION_STRING;

1;

__END__

=head1 NAME

Sigrok::SerialPort::Backend - XS module providing an interface to the API of the C library libserialport

=head1 SYNOPSIS

  use Sigrok::SerialPort::Backend qw( :all );
  
  my $port;
  sp_get_port_by_name("COM3", \$port);
  print sp_get_port_description($port);
 
  sub DESTROY {
    sp_free_port($port);
  }

=head1 DESCRIPTION

L<libserialport|http://sigrok.org/wiki/Libserialport> is a small,
well-documented C library for general-purpose serial port communication. This is
a perl wrapper for the library.

=head2 EXPORT

=head3 Port enumeration

=over 12

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

  $ret = sp_set_cts($port, SP_CTS_OFF);

=item C<sp_get_config_cts>

Get the CTS pin behaviour from a port configuration.

  $ret = sp_get_config_cts($config, \$cts);

=item C<sp_set_config_cts>

Set the CTS pin behaviour in a port configuration.

  $ret = sp_set_config_cts($config, SP_CTS_ON);

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

J. Schneider

=head1 COPYRIGHT AND LICENSE

=over 4

=item *

Copyright (C) 2013, 2015 Martin Ling <martin-libserialport@earth.li>

=item *

Copyright (C) 2014 Uwe Hermann <uwe@hermann-uwe.de>

=item *

Copyright (C) 2014 Aurelien Jacobs <aurel@gnuage.org>

=item *

Copyright (C) 2019 J. Schneider L<https://github.com/brickpool>

=back

This library is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

=cut
