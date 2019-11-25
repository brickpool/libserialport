package Sigrok::SerialPort;

use strict;
use warnings;

use Exporter;

our $VERSION = 0.0201;

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

Sigrok::SerialPort - module providing all constants of the C library
libserialport

=head1 SYNOPSIS

  use Sigrok::SerialPort qw( :const );
  
  my $ver = SP_PACKAGE_VERSION_STRING;
  print "libserialport package version: $ver\n";

=head2 EXPORT

=head3 :const

=over 12

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

=item C<# Port access modes>

Open port for read access.

  SP_MODE_READ = 1,

Open port for write access.

  SP_MODE_WRITE = 2,

Open port for read and write access.

  SP_MODE_READ_WRITE = 3

=item C<# Port events>

Data received and ready to read.

  SP_EVENT_RX_READY = 1

Ready to transmit new data.

  SP_EVENT_TX_READY = 2

Error occurred.

  SP_EVENT_ERROR = 4

=item C<# Buffer selection>

Input buffer.

  SP_BUF_INPUT = 1

Output buffer.

  SP_BUF_OUTPUT = 2

Both buffers.

  SP_BUF_BOTH = 3

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

=item C<# Input signals>

Clear to send.

  SP_SIG_CTS = 1

Data set ready.

  SP_SIG_DSR = 2

Data carrier detect.

  SP_SIG_DCD = 4

Ring indicator.

  SP_SIG_RI = 8

=item C<# Transport types>

Native platform serial port.

  SP_TRANSPORT_NATIVE,

USB serial port adapter.

  SP_TRANSPORT_USB,

Bluetooth serial port adapter.

  SP_TRANSPORT_BLUETOOTH

=back

=head3 :version

=over 12

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
