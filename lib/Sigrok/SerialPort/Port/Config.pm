package Sigrok::SerialPort::Port::Config;

use Moose;
use MooseX::Params::Validate;
use Carp qw( croak );
use English qw( -no_match_vars );
use Errno qw( :POSIX );

use Sigrok::SerialPort qw(
  SP_OK

  sp_new_config
  sp_free_config
  sp_get_config
  sp_set_config
  sp_set_baudrate
  sp_get_config_baudrate
  sp_set_config_baudrate
  sp_get_config_bits
  sp_set_config_bits
  sp_get_config_parity
  sp_set_config_parity
  sp_get_config_stopbits
  sp_set_config_stopbits
  sp_get_config_rts
  sp_set_config_rts
  sp_get_config_cts
  sp_set_config_cts
  sp_get_config_dtr
  sp_set_config_dtr
  sp_get_config_dsr
  sp_set_config_dsr
  sp_get_config_xon_xoff
  sp_set_config_xon_xoff
  sp_set_config_flowcontrol
);
use Sigrok::SerialPort::Error qw(
  SET_ERROR
);

extends 'Sigrok::SerialPort::Base';

##
#
# Configuration
#
##

has 'config_handle' => (
  isa       => 'sp_port_config',
  required  => 1,
  lazy      => 1,
  init_arg  => 'handle',
  reader    => 'get_handle',
  # private methods
  builder   => '_build_handle',
);

has 'baudrate' => (
  isa       => 'Maybe[sp_baudrate]',
  default   => -1,
  reader    => 'get_baudrate',
  writer    => 'set_baudrate',
  # private methods
  trigger   => \&_trigger_baudrate,
);

has 'bits' => (
  isa       => 'Maybe[sp_databits]',
  default   => -1,
  reader    => 'get_bits',
  writer    => 'set_bits',
  # private methods
  trigger   => \&_trigger_bits,
);

has 'parity' => (
  isa       => 'Maybe[sp_parity]',
  default   => -1,
  reader    => 'get_parity',
  writer    => 'set_parity',
  # private methods
  trigger   => \&_trigger_parity,
);

has 'stopbits' => (
  isa       => 'Maybe[sp_stopbits]',
  default   => -1,
  reader    => 'get_stopbits',
  writer    => 'set_stopbits',
  # private methods
  trigger   => \&_trigger_stopbits,
);

has 'rts' => (
  isa       => 'Maybe[sp_rts]',
  default   => -1,
  reader    => 'get_rts',
  writer    => 'set_rts',
  # private methods
  trigger   => \&_trigger_rts,
);

has 'cts' => (
  isa       => 'Maybe[sp_cts]',
  default   => -1,
  reader    => 'get_cts',
  writer    => 'set_cts',
  # private methods
  trigger   => \&_trigger_cts,
);

has 'dtr' => (
  isa       => 'Maybe[sp_dtr]',
  default   => -1,
  reader    => 'get_dtr',
  writer    => 'set_dtr',
  # private methods
  trigger   => \&_trigger_dtr,
);

has 'dsr' => (
  isa       => 'Maybe[sp_dsr]',
  default   => -1,
  reader    => 'get_dsr',
  writer    => 'set_dsr',
  # private methods
  trigger   => \&_trigger_dsr,
);

has 'xon_xoff' => (
  isa       => 'Maybe[sp_xonxoff]',
  default   => -1,
  reader    => 'get_xon_xoff',
  writer    => 'set_xon_xoff',
  # private methods
  trigger   => \&_trigger_xon_xoff,
);

has 'flowcontrol' => (
  isa       => 'Maybe[sp_flowcontrol]',
  writer    => 'set_flowcontrol',
  # private methods
  trigger   => \&_trigger_flowcontrol,
);

##
#
# extends accessor methods
#
##

before 'get_baudrate' => sub {
  my $self = shift;
  $self->{baudrate} = $self->_get_config_baudrate;
};

before 'get_bits' => sub {
  my $self = shift;
  $self->{bits} = $self->_get_config_bits;
};

before 'get_parity' => sub {
  my $self = shift;
  $self->{parity} = $self->_get_config_parity;
};

before 'get_stopbits' => sub {
  my $self = shift;
  $self->{stopbits} = $self->_get_config_stopbits;
};

before 'get_rts' => sub {
  my $self = shift;
  $self->{rts} = $self->_get_config_rts;
};

before 'get_cts' => sub {
  my $self = shift;
  $self->{cts} = $self->_get_config_cts;
};

before 'get_dtr' => sub {
  my $self = shift;
  $self->{dtr} = $self->_get_config_dtr;
};

before 'get_dsr' => sub {
  my $self = shift;
  $self->{dsr} = $self->_get_config_dsr;
};

before 'get_xon_xoff' => sub {
  my $self = shift;
  $self->{xon_xoff} = $self->_get_config_xon_xoff;
};

##
#
# extends default methods
#
##

sub DEMOLISH {
  my $self = shift;
  $self->_free_config if $self->get_handle
}

##
#
# additional public methods
#
##

sub cget {
  my $self = shift;
  my ($option) = pos_validated_list( \@_,
    { isa => 'Str' },
  );
  $option =~ s/^\b/\-/;  # option => -option
  my $ret_val;
  SWITCH: for ($option) {
    /^-baudrate$/ && do { $ret_val = $self->get_baudrate; last };
    /^-bits$/     && do { $ret_val = $self->get_bits;     last };
    /^-parity$/   && do { $ret_val = $self->get_parity;   last };
    /^-stopbits$/ && do { $ret_val = $self->get_stopbits; last };
    /^-rts$/      && do { $ret_val = $self->get_rts;      last };
    /^-cts$/      && do { $ret_val = $self->get_cts;      last };
    /^-dtr$/      && do { $ret_val = $self->get_dtr;      last };
    /^-dsr$/      && do { $ret_val = $self->get_dsr;      last };
    /^-xon_xoff$/ && do { $ret_val = $self->get_xon_xoff; last };
    DEFAULT: {
      croak "Validation failed for 'option' with value $_ " .
            "(-baudrate|-bits|-parity|-stopbits|-rts|-cts|-dtr|-dsr|-xon_xoff) is required";
    }
  }
  defined ($ret_val)
    or return wantarray ? () : undef;
  return $ret_val;
}

sub configure {
  my $self = shift;
  unless (@_) {
    unless ($self->get_handle) {
      # The value of the config argument is invalid.
      SET_ERROR(ENXIO); # No such device or address
      return wantarray ? () : undef;
    }
    my @ret_val = qw(-baudrate -bits -parity -stopbits -rts -cts -dtr -dsr -xon_xoff -flowcontrol);
    return wantarray ? @ret_val : scalar @ret_val;
  }
  my (%options) = validated_hash( \@_,
    '-baudrate'    => { isa => 'sp_baudrate',    optional => 1 },
    '-bits'        => { isa => 'sp_databits',    optional => 1 },
    '-parity'      => { isa => 'sp_parity',      optional => 1 },
    '-stopbits'    => { isa => 'sp_stopbits',    optional => 1 },
    '-rts'         => { isa => 'sp_rts',         optional => 1 },
    '-cts'         => { isa => 'sp_cts',         optional => 1 },
    '-dtr'         => { isa => 'sp_dtr',         optional => 1 },
    '-dsr'         => { isa => 'sp_dsr',         optional => 1 },
    '-xon_xoff'    => { isa => 'sp_xonxoff',     optional => 1 },
    '-flowcontrol' => { isa => 'sp_flowcontrol', optional => 1 },
  );
  my $cnt = 0;
  while ( my ($key, $value) = each %options ) {
    SWITCH: for ($key) {
      /^-baudrate$/     && do { defined $self->set_baudrate($value)     or return wantarray ? () : undef; last };
      /^-bits$/         && do { defined $self->set_bits($value)         or return wantarray ? () : undef; last };
      /^-parity$/       && do { defined $self->set_parity($value)       or return wantarray ? () : undef; last };
      /^-stopbits$/     && do { defined $self->set_stopbits($value)     or return wantarray ? () : undef; last };
      /^-rts$/          && do { defined $self->set_rts($value)          or return wantarray ? () : undef; last };
      /^-cts$/          && do { defined $self->set_cts($value)          or return wantarray ? () : undef; last };
      /^-dtr$/          && do { defined $self->set_dtr($value)          or return wantarray ? () : undef; last };
      /^-dsr$/          && do { defined $self->set_dsr($value)          or return wantarray ? () : undef; last };
      /^-xon_xoff$/     && do { defined $self->set_xon_xoff($value)     or return wantarray ? () : undef; last };
      /^-flowcontrol$/  && do { defined $self->set_flowcontrol($value)  or return wantarray ? () : undef; last };
    }
    $cnt++
  }
  return wantarray ? values %options : $cnt;
}

##
#
# private build methods
#
##

sub _build_handle {
  my $self = shift;
  my $ret_val;
  my $ret_code = sp_new_config(\$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return 0;
  }
  unless ($ret_val > 0) {
    # The value provided for the handle is not positive.
    SET_ERROR(EFAULT); # Bad address
    return 0;
  }
  return $ret_val;
}

##
#
# private trigger methods
#
##

sub _trigger_baudrate {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_baudrate' },
    { isa => 'sp_baudrate', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_baudrate($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_bits {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_databits' },
    { isa => 'sp_databits', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_bits($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_parity {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_parity' },
    { isa => 'sp_parity', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_parity($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_stopbits {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_stopbits' },
    { isa => 'sp_stopbits', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_stopbits($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_rts {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_rts' },
    { isa => 'sp_rts', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_rts($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_cts {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_cts' },
    { isa => 'sp_cts', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_cts($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_dtr {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_dtr' },
    { isa => 'sp_dtr', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_dtr($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_dsr {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_dsr' },
    { isa => 'sp_dsr', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_dsr($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_xon_xoff {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_xonxoff' },
    { isa => 'sp_xonxoff', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_xon_xoff($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_flowcontrol {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_flowcontrol' },
    { isa => 'sp_flowcontrol', optional => 1 },
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_set_config_flowcontrol($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

##
#
# private backend wrapper methods
#
##

sub _get_config_baudrate {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_baudrate($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_bits {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_bits($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_parity {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_parity($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_stopbits {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_stopbits($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_rts {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_rts($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_cts {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_cts($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_dtr {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_dtr($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_dsr {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_dsr($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _get_config_xon_xoff {
  my $self = shift;
  my $ret_val;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_get_config_xon_xoff($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
};

sub _free_config {
  my $self = shift;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  sp_free_config($self->get_handle);
  return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sigrok::SerialPort::Config - represents a port configuration.

=head1 SYNOPSIS

  use Sigrok::SerialPort::Port;
  
  my $port;
  eval { $port = Sigrok::SerialPort::Port->new(portname => 'COM3') }
    or die @_;
  for ($port->config) {
    printf("Baudrate: %d\n", $_->cget('-baudrate'));
    printf("Bits:     %d\n", $_->cget('-bits')    );
    printf("Parity:   %d\n", $_->cget('-parity')  );
    printf("Stopbits: %d\n", $_->cget('-stopbits'));
  }

=head1 DESCRIPTION

The C<Sigrok::SerialPort::Config> module setting and querying serial port
parameters (baud rate, parity, etc.).

Usually the objects of type C<Sigrok::SerialPort::Config> are not created
directly by the user. The object of the type C<Sigrok::SerialPort::Port> is
responsible for this. 

The I<values> provided by the configuration methods are documented in detail in
the C<Sigrok::SerialPort::Base> package.

=head2 EXPORT

=over 12

=item C<new()>

=item C<< new(I<< '-option' => value, '-option' => value, ... >>) >>

The constructor C<new> return a new configuration object. The constructor
internally allocates an structure of type C<sp_config>. 

  $obj = Sigrok::SerialPort::Config->new;

If required, I<< -option => value >> pairs can be passed by the constructor. 

=item C<< @list = configure('-option' => valueI<< , '-option' => value,
... >>) >>

=item C<< $scalar = configure('-option' => valueI<< , '-option' => value,
... >>) >>

Sets the values of I<-option> to I<value> for each I<< '-option' => value >>
pair. Valid options are C<-baudrate, -bits, -parity, -stopbits, -rts, -cts,
-dtr, -dsr, -xon_xoff, -flowcontrol>. The C<'> character is necessary due to
perl's parsing rules.

  $port->config->configure('-baudrate' => 9600, '-bits' => 8) || die $!;
  $port->write_settings || die $!;

In the list context, all applied values of the options are returned. In scalar
context, the number of options is returned. If an error occurs, C<undef> is
returned.

Please note that the C<configure> method does not implicit apply the options to
a serial port. This must be done by an C<Sigrok::SerialPort::Port> object.

=item C<@list = configure()>

=item C<$scalar = configure()>

In the list context, all valid options are returned. In scalar context, the
number of options is returned. If an error occurs, C<undef> is returned.

  print 'configure returns ', scalar $obj->configure, " number of options.\n";
  print "valid options are: \n";
  print join "\n", $obj->configure;

=item C<cget('-options')>

Returns the current value of C<-option> of a configuration object. C<cget>
returned C<undef> if an error occurs. 

  $baud = $port->config->cget('-baudrate') || die $!;

Valid options are C<-baudrate, -bits, -parity, -stopbits, -rts, -cts, -dtr,
-dsr, -xon_xoff>. The C<'> character is necessary due to perl's parsing rules.

Please note that the C<cget> method does not read the option from a serial port.
This must be done by an C<Sigrok::SerialPort::Port> object.

=item C<set_baudrate($baudrate)>

=item C<set_bits($bits)>

=item C<set_parity($parity)>

=item C<set_stopbits($stopbits)>

=item C<set_rts($rts)>

=item C<set_cts($cts)>

=item C<set_dtr($dtr)>

=item C<set_dsr($dsr)>

=item C<set_xon_xoff($xon_xoff)>

=item C<set_flowcontrol($flowcontrol)>

Standard set methods. Alias for C<< configure('-option' => value) >>.

  # $obj->configure('-baudrate' => 9600) || die $!;
  $obj->set_baudrate(9600) || die $!;

The set methods return the specified value or C<undef> if an error occurs.

=item C<get_baudrate()>

=item C<get_bits()>

=item C<get_parity()>

=item C<get_stopbits()>

=item C<get_rts()>

=item C<get_cts()>

=item C<get_dtr()>

=item C<get_dsr()>

=item C<get_xon_xoff()>

Standard get methods. Alias for C<cget('-option')>.

  # $baud = $obj->cget('-baudrate') || die $!;
  $baud = $obj->get_baudrate() || die $!;

The get methods returned C<undef> if an error occurs.

=item C<get_handle()>
C<get_handle> gives you access to the internal structure of type C<sp_config>. 
The assigned internal structure is automatically created by the C<new>
constructor and freeded by the destructor.

  $handle = $obj->get_handle() || die $!;

The handle can be used for direct libserialport API calls to the
C<Sigrok::SerialPort> backend library.

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
