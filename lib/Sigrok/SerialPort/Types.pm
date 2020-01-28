package Sigrok::SerialPort::Types;

# Serialport library
use Sigrok::SerialPort qw(
  :const
);

# Use of Modern Perl
use Types::Standard qw( ArrayRef Enum Int Str );
use Types::Common::Numeric qw( PositiveOrZeroInt );
# Using -base from Type::Library sets your package up as an exporter that
# inherits from Type::Library.
# Using -declare allows the type constraints there to be written as barewords in
# the rest of the package
use Type::Library -base, -declare => qw(
                      Int_sp_return
  Enum_sp_mode        Int_sp_mode
  Enum_sp_event       Int_sp_event
  Enum_sp_buffer      Int_sp_buffer
  Enum_sp_parity      Int_sp_parity
  Enum_sp_rts         Int_sp_rts
  Enum_sp_cts         Int_sp_cts
  Enum_sp_dsr         Int_sp_dsr
  Enum_sp_xonxoff     Int_sp_xonxoff
  Enum_sp_flowcontrol Int_sp_flowcontrol
                      Int_sp_signal
);
# Importing from Type::Utils gives you a bunch of helpful keywords which will be
# pretty familiar to type constraints in Moose or MooseX::Types
# The 'declare', 'as', and 'where' keywords are some of the things exported by
# Type::Utils.
use Type::Utils -all;

##
#
# enum types (from libserialport)
#
##

declare Int_sp_return,
  as Int,
  where { $_ >= SP_ERR_SUPP && $_ <= SP_OK },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_return' with value $_ " .
    "(did you use the 'SP_OK|SP_ERR_...' constants?)"
  };

declare Enum_sp_mode,
  as Enum[qw(
    SP_MODE_READ
    SP_MODE_WRITE
    SP_MODE_READ_WRITE
  )];

declare Int_sp_mode,
  as Int,
  where { $_ >= SP_MODE_READ && $_ <= SP_MODE_READ_WRITE },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_mode' with value $_ " .
    "(did you use the 'SP_MODE_...' constants?) "
  };

coerce Int_sp_mode,
  from Enum_sp_mode,
  via {
    SWITCH: {
      /^SP_MODE_READ$/        && do { return SP_MODE_READ       };
      /^SP_MODE_WRITE$/       && do { return SP_MODE_WRITE      };
      /^SP_MODE_READ_WRITE$/  && do { return SP_MODE_READ_WRITE };
    }
  };

coerce Int_sp_mode,
  from ArrayRef[Enum_sp_mode],
  via {
    my $ret_val = 0;
    foreach ( @{$_[0]} ) {
      SWITCH: {
        /^SP_MODE_READ$/        && do { $ret_val |= SP_MODE_READ;       last };
        /^SP_MODE_WRITE$/       && do { $ret_val |= SP_MODE_WRITE;      last };
        /^SP_MODE_READ_WRITE$/  && do { $ret_val |= SP_MODE_READ_WRITE; last };
      }
    }
    return $ret_val;
  };

declare Enum_sp_event,
  as Enum[qw(
    SP_EVENT_RX_READY
    SP_EVENT_TX_READY
    SP_EVENT_ERROR
  )];

declare Int_sp_event,
  as Int,
  where { $_ > 0 && $_ <= SP_EVENT_RX_READY+SP_EVENT_TX_READY+SP_EVENT_ERROR },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_event' with value $_ " .
    "(did you use the 'SP_EVENT_...' constants?)"
  };

coerce Int_sp_event,
  from Enum_sp_event,
  via {
    SWITCH: {
      /^SP_EVENT_RX_READY$/ && do { return SP_EVENT_RX_READY  };
      /^SP_EVENT_TX_READY$/ && do { return SP_EVENT_TX_READY  };
      /^SP_EVENT_ERROR$/    && do { return SP_EVENT_ERROR     };
    }
  };

coerce Int_sp_event,
  from ArrayRef[Enum_sp_event],
  via {
    my $ret_val = 0;
    foreach ( @{$_[0]} ) {
      SWITCH: {
        /^SP_EVENT_RX_READY$/ && do { $ret_val |= SP_EVENT_RX_READY;  last };
        /^SP_EVENT_TX_READY$/ && do { $ret_val |= SP_EVENT_TX_READY;  last };
        /^SP_EVENT_ERROR$/    && do { $ret_val |= SP_EVENT_ERROR;     last };
      }
    }
    return $ret_val;
  };

declare Enum_sp_buffer,
  as Enum[qw(
    SP_BUF_INPUT
    SP_BUF_OUTPUT
    SP_BUF_BOTH
  )];

declare Int_sp_buffer,
  as Int,
  where { $_ >= SP_BUF_INPUT && $_ <= SP_BUF_BOTH },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_buffer' with value $_ " .
    "(did you use the 'SP_BUF_...' constants?)"
  };

coerce Int_sp_buffer,
  from Enum_sp_buffer,
  via {
    SWITCH: {
      /^SP_BUF_INPUT$/  && do { return SP_BUF_INPUT   };
      /^SP_BUF_OUTPUT$/ && do { return SP_BUF_OUTPUT  };
      /^SP_BUF_BOTH$/   && do { return SP_BUF_BOTH    };
    }
  };

coerce Int_sp_buffer,
  from ArrayRef[Enum_sp_buffer],
  via {
    my $ret_val = 0;
    foreach ( @{$_[0]} ) {
      SWITCH: {
        /^SP_BUF_INPUT$/  && do { $ret_val |= SP_BUF_INPUT;  last };
        /^SP_BUF_OUTPUT$/ && do { $ret_val |= SP_BUF_OUTPUT; last };
        /^SP_BUF_BOTH$/   && do { $ret_val |= SP_BUF_BOTH;   last };
      }
    }
    return $ret_val;
  };

declare Enum_sp_parity,
  as Enum[qw(
    SP_PARITY_INVALID
    SP_PARITY_NONE
    SP_PARITY_ODD
    SP_PARITY_EVEN
    SP_PARITY_MARK
    SP_PARITY_SPACE
  )];

declare Int_sp_parity,
  as Int,
  where { $_ == -1 || $_ >= SP_PARITY_INVALID && $_ <= SP_PARITY_SPACE },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_parity' with value $_ " .
    "(did you use the 'SP_PARITY_...' constants?)"
  };

coerce Int_sp_parity,
  from Enum_sp_parity,
  via {
    SWITCH: {
      /^SP_PARITY_INVALID$/ && do { return SP_PARITY_INVALID  };
      /^SP_PARITY_NONE$/    && do { return SP_PARITY_NONE     };
      /^SP_PARITY_ODD$/     && do { return SP_PARITY_ODD      };
      /^SP_PARITY_EVEN$/    && do { return SP_PARITY_EVEN     };
      /^SP_PARITY_MARK$/    && do { return SP_PARITY_MARK     };
      /^SP_PARITY_SPACE$/   && do { return SP_PARITY_SPACE    };
    }
  };

declare Enum_sp_rts,
  as Enum[qw(
    SP_RTS_INVALID
    SP_RTS_OFF
    SP_RTS_ON
    SP_RTS_FLOW_CONTROL
  )];

declare Int_sp_rts,
  as Int,
  where { $_ == -1 || $_ >= SP_RTS_INVALID && $_ <= SP_RTS_FLOW_CONTROL },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_rts' with value $_ " .
    "(did you use the 'SP_RTS_...' constants?)"
  };

coerce Int_sp_rts,
  from Enum_sp_rts,
  via {
    SWITCH: {
      /^SP_RTS_INVALID$/      && do { return SP_RTS_INVALID       };
      /^SP_RTS_OFF$/          && do { return SP_RTS_OFF           };
      /^SP_RTS_ON$/           && do { return SP_RTS_ON            };
      /^SP_RTS_FLOW_CONTROL$/ && do { return SP_RTS_FLOW_CONTROL  };
    }
  };

declare Enum_sp_cts,
  as Enum[qw(
    SP_CTS_INVALID
    SP_CTS_IGNORE
    SP_CTS_FLOW_CONTROL
  )];

declare Int_sp_cts,
  as Int,
  where { $_ == -1 || $_ >= SP_CTS_INVALID && $_ <= SP_CTS_FLOW_CONTROL },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_cts' with value $_ " .
    "(did you use the 'SP_CTS_...' constants?)"
  };

coerce Int_sp_cts,
  from Enum_sp_cts,
  via {
    SWITCH: {
      /^SP_CTS_INVALID$/      && do { return SP_CTS_INVALID       };
      /^SP_CTS_IGNORE$/       && do { return SP_CTS_IGNORE        };
      /^SP_CTS_FLOW_CONTROL$/ && do { return SP_CTS_FLOW_CONTROL  };
    }
  };

declare Enum_sp_dtr,
  as Enum[qw(
    SP_DTR_INVALID
    SP_DTR_OFF
    SP_DTR_ON
    SP_DTR_FLOW_CONTROL
  )];
  
declare Int_sp_dtr,
  as Int,
  where { $_ == -1 || $_ >= SP_DTR_INVALID && $_ <= SP_DTR_FLOW_CONTROL },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_dtr' with value $_ " .
    "(did you use the 'SP_DTR_...' constants?)"
  };

coerce Int_sp_dtr,
  from Enum_sp_dtr,
  via {
    SWITCH: {
      /^SP_DTR_INVALID$/      && do { return SP_DTR_INVALID       };
      /^SP_DTR_OFF$/          && do { return SP_DTR_OFF           };
      /^SP_DTR_ON$/           && do { return SP_DTR_ON            };
      /^SP_DTR_FLOW_CONTROL$/ && do { return SP_DTR_FLOW_CONTROL  };
    }
  };

declare Enum_sp_dsr,
  as Enum[qw(
    SP_DSR_INVALID
    SP_DSR_IGNORE
    SP_DSR_FLOW_CONTROL
  )];
  
declare Int_sp_dsr,
  as Int,
  where { $_ == -1 || $_ >= SP_DSR_INVALID && $_ <= SP_DSR_FLOW_CONTROL },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_dsr' with value $_ " .
    "(did you use the 'SP_DSR_...' constants?)"
  };

coerce Int_sp_dsr,
  from Enum_sp_dsr,
  via {
    SWITCH: {
      /^SP_DSR_INVALID$/      && do { return SP_DSR_INVALID       };
      /^SP_DSR_IGNORE$/       && do { return SP_DSR_IGNORE        };
      /^SP_DSR_FLOW_CONTROL$/ && do { return SP_DSR_FLOW_CONTROL  };
    }
  };

declare Enum_sp_xonxoff,
  as Enum[qw(
    SP_XONXOFF_INVALID
    SP_XONXOFF_DISABLED
    SP_XONXOFF_IN
    SP_XONXOFF_OUT
    SP_XONXOFF_INOUT
  )];

declare Int_sp_xonxoff,
  as Int,
  where { $_ == -1 || $_ >= SP_XONXOFF_INVALID && $_ <= SP_XONXOFF_INOUT },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_xonxoff' with value $_ " .
    "(did you use the 'SP_XONXOFF_...' constants?)"
  };

coerce Int_sp_xonxoff,
  from Enum_sp_xonxoff,
  via {
    SWITCH: {
      /^SP_XONXOFF_INVALID$/  && do { return SP_XONXOFF_INVALID   };
      /^SP_XONXOFF_DISABLED$/ && do { return SP_XONXOFF_DISABLED  };
      /^SP_XONXOFF_IN$/       && do { return SP_XONXOFF_IN        };
      /^SP_XONXOFF_OUT$/      && do { return SP_XONXOFF_OUT       };
      /^SP_XONXOFF_INOUT$/    && do { return SP_XONXOFF_INOUT     };
    }
  };

coerce Int_sp_xonxoff,
  from ArrayRef[Enum_sp_xonxoff],
  via {
    my $ret_val = 0;
    foreach ( @{$_[0]} ) {
      SWITCH: {
        /^SP_XONXOFF_INVALID$/  && do { $ret_val |= SP_XONXOFF_INVALID;   last };
        /^SP_XONXOFF_DISABLED$/ && do { $ret_val |= SP_XONXOFF_DISABLED;  last };
        /^SP_XONXOFF_IN$/       && do { $ret_val |= SP_XONXOFF_IN;        last };
        /^SP_XONXOFF_OUT$/      && do { $ret_val |= SP_XONXOFF_OUT;       last };
        /^SP_XONXOFF_INOUT$/    && do { $ret_val |= SP_XONXOFF_INOUT;     last };
      }
    }
    return $ret_val;
  };

declare Enum_sp_flowcontrol,
  as Enum[qw(
    SP_FLOWCONTROL_NONE
    SP_FLOWCONTROL_XONXOFF
    SP_FLOWCONTROL_RTSCTS
    SP_FLOWCONTROL_DTRDSR
  )];

declare Int_sp_flowcontrol,
  as Int,
  where { $_ >= SP_FLOWCONTROL_NONE && $_ <= SP_FLOWCONTROL_DTRDSR },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_dsr' with value $_ " .
    "(did you use the 'SP_FLOWCONTROL_...' constants?)"
  };

coerce Int_sp_flowcontrol,
  from Enum_sp_flowcontrol,
  via {
    SWITCH: {
      /^SP_FLOWCONTROL_NONE$/     && do { return SP_FLOWCONTROL_NONE    };
      /^SP_FLOWCONTROL_XONXOFF$/  && do { return SP_FLOWCONTROL_XONXOFF };
      /^SP_FLOWCONTROL_RTSCTS$/   && do { return SP_FLOWCONTROL_RTSCTS  };
      /^SP_FLOWCONTROL_DTRDSR$/   && do { return SP_FLOWCONTROL_DTRDSR  };
    }
  };

declare Int_sp_signal,
  as Int,
  where { $_ >= 0 && $_ <= SP_SIG_CTS+SP_SIG_DSR+SP_SIG_DCD+SP_SIG_RI },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_signal' with value $_ " .
    "(did you use the 'SP_SIG_...' constants?)"
  };

declare Enum_sp_transport,
  as Enum[qw(
    SP_TRANSPORT_NATIVE
    SP_TRANSPORT_USB
    SP_TRANSPORT_BLUETOOTH
  )];

declare Int_sp_transport,
  as Int,
  where { $_ >= SP_TRANSPORT_NATIVE && $_ <= SP_TRANSPORT_BLUETOOTH },
  message {
    Int->validate($_) or
    "Validation failed for 'sp_transport' with value $_ " .
    "(did you use the 'SP_TRANSPORT_...' constants?)"
  };

coerce Int_sp_transport,
  from Enum_sp_transport,
  via {
    SWITCH: {
      /^SP_TRANSPORT_NATIVE$/     && do { return SP_TRANSPORT_NATIVE    };
      /^SP_TRANSPORT_USB$/        && do { return SP_TRANSPORT_USB       };
      /^SP_TRANSPORT_BLUETOOTH$/  && do { return SP_TRANSPORT_BLUETOOTH };
    }
  };

##
#
# struct types (from libserialport)
#
##

declare Int_sp_port,
  as PositiveOrZeroInt;

declare Int_sp_port_config,
  as PositiveOrZeroInt;

declare Int_sp_event_set,
  as PositiveOrZeroInt;

##
#
# additional types
#
##

declare Int_sp_baudrate,
  as Int,
  where { /^(?:\-1|50|75|110|134|150|200|300|600|1200|1800|2400|4800|9600|14400|19200|38400|57600|115200|128000|230400|256000|460800)$/ };

declare Int_sp_databits,
  as Int,
  where { $_ == -1 || $_ >= 5 && $_ <= 8 };

declare Int_sp_stopbits,
  as Int,
  where { $_ == -1 || $_ == 1 || $_ == 2 };

1;

__END__

=head1 NAME

Sigrok::SerialPort::Types - is a type library for all SerialPort objects

=head1 SYNOPSIS

  use Moo;    
  use Sigrok::SerialPort::Types qw( sp_port );
    
  has 'port_handle' => (
    isa       => Int_sp_port,
    is        => wr,
    init_arg  => undef,
  );

=head1 DESCRIPTION

So it is helpful to make my own application-specific type library.

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

=back

=head1 SEE ALSO

Please see those websites for more information related to the library.

=over 4

=item *

L<Type::Tiny homepage|http://typetiny.toby.ink>

=item *

L<Type::Tiny on CPAN|https://metacpan.org/release/Type-Tiny>

=back

=head1 SOURCE

Source repository is at L<https://github.com/brickpool/libserialport>.

=head1 AUTHOR

J. Schneider L<https://github.com/brickpool>

=head1 COPYRIGHT AND LICENSE

=over 4

=item *

Copyright (c) 2013-2014, 2017-2020 Toby Inkster L<http://typetiny.toby.ink>
 
=item *

Copyright (C) 2020 J. Schneider L<https://github.com/brickpool>

=back

This is free software; you can redistribute it and/or modify it under the
same terms as the Perl 5 programming language system itself

=cut
