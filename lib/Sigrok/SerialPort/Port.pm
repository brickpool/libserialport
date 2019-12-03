package Sigrok::SerialPort::Port;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate;
use Carp qw( croak );
use English qw( -no_match_vars );
use Errno qw( :POSIX );

use Sigrok::SerialPort qw(
  SP_OK
  SP_ERR_ARG
  SP_ERR_SUPP

  SP_MODE_READ
  SP_MODE_WRITE
  
  SP_TRANSPORT_NATIVE
  SP_TRANSPORT_USB
  SP_TRANSPORT_BLUETOOTH

  sp_get_port_by_name
  sp_free_port
  sp_copy_port

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

  sp_get_config
  sp_set_config
  sp_set_baudrate
  sp_set_bits
  sp_set_parity
  sp_set_stopbits
  sp_set_rts
  sp_set_cts
  sp_set_dtr
  sp_set_dsr
  sp_set_xon_xoff
  sp_set_flowcontrol

  sp_blocking_read
  sp_blocking_read_next
  sp_nonblocking_read
  sp_blocking_write
  sp_nonblocking_write
  sp_input_waiting
  sp_output_waiting
  sp_flush
  sp_drain

  sp_get_signals
  sp_start_break
  sp_end_break

  sp_last_error_message
);
use Sigrok::SerialPort::Error qw(
  SET_ERROR
);
use Sigrok::SerialPort::Port::Config;

extends 'Sigrok::SerialPort::Base';

##
#
# Port enumeration
#
##

has 'port_handle' => (
  isa       => 'sp_port',
  init_arg  => 'undef',
  reader    => 'get_handle',
);

##
#
# Port handling
#
##

has 'mode' => (
  isa       => 'Maybe[sp_mode]',
  reader    => 'get_mode',
);

has 'is_open' => (
  is        => 'ro',
  isa       => 'Bool',
  init_arg  => 'undef',
  default   => 0,
);

has 'name' => (
  isa       => 'Maybe[Str]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_name',
  # private methods
  builder   => '_build_name',
);

has 'description' => (
  isa       => 'Maybe[Str]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_description',
  # private methods
  builder   => '_build_description',
);

has 'transport' => (
  isa       => 'Maybe[sp_transport]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_transport',
  # private methods
  builder   => '_build_transport',
);

has 'usb_bus' => (
  isa       => 'Maybe[Int]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_bus',
  # private methods
  builder   => '_build_usb_bus',
);

has 'usb_address' => (
  isa       => 'Maybe[Int]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_address',
  # private methods
  builder   => '_build_usb_address',
);

has 'usb_vid' => (
  isa       => 'Maybe[Int]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_vid',
  # private methods
  builder   => '_build_usb_vid',
);

has 'usb_pid' => (
  isa       => 'Maybe[Int]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_pid',
  # private methods
  builder   => '_build_usb_pid',
);

has 'usb_manufacturer' => (
  isa       => 'Maybe[Str]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_manufacturer',
  # private methods
  builder   => '_build_usb_manufacturer',
);

has 'usb_product' => (
  isa       => 'Maybe[Str]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_product',
  # private methods
  builder   => '_build_usb_product',
);

has 'usb_serial' => (
  isa       => 'Maybe[Str]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_serial',
  # private methods
  builder   => '_build_usb_serial',
);

has 'bluetooth_address' => (
  isa       => 'Maybe[Str]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_bluetooth_address',
  # private methods
  builder   => '_build_bluetooth_address',
);

has 'native_handle' => (
  isa       => 'Any',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_native_handle',
  # private methods
  builder   => '_build_native_handle',
);

##
#
# Configuration
#
##

has 'config' => (
  is          => 'rw',
  isa         => 'Sigrok::SerialPort::Port::Config',
  lazy_build  => 1,
  init_arg    => 'undef',
);

has 'baudrate' => (
  isa       => 'Maybe[sp_baudrate]',
  writer    => 'set_baudrate',
);

has 'bits' => (
  isa       => 'Maybe[sp_databits]',
  writer    => 'set_bits',
);

has 'parity' => (
  isa       => 'Maybe[sp_parity]',
  writer    => 'set_parity',
);

has 'stopbits' => (
  isa       => 'Maybe[sp_stopbits]',
  writer    => 'set_stopbits',
);

has 'rts' => (
  isa       => 'Maybe[sp_rts]',
  writer    => 'set_rts',
);

has 'cts' => (
  isa       => 'Maybe[sp_cts]',
  writer    => 'set_cts',
);

has 'dtr' => (
  isa       => 'Maybe[sp_dtr]',
  writer    => 'set_dtr',
);

has 'dsr' => (
  isa       => 'Maybe[sp_dsr]',
  writer    => 'set_dsr',
);

has 'xon_xoff' => (
  isa       => 'Maybe[sp_xonxoff]',
  writer    => 'set_xon_xoff',
);

has 'flowcontrol' => (
  isa       => 'Maybe[sp_flowcontrol]',
  writer    => 'set_flowcontrol',
);

##
#
# Data handling
#
##

has 'buffers' => (
  isa       => 'sp_buffer',
  init_arg  => 'undef',
  writer    => 'flush',
  # private methods
  trigger   => \&_trigger_flush,
);

##
#
# Signals
#
##

has 'signal_mask' => (
  isa       => 'Maybe[sp_signal]',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_signals',
  # private methods
  builder   => '_build_signals',
);

##
#
# helper attributes
#
##

coerce 'sp_port' =>
  from 'Sigrok::SerialPort::Port' =>
  via { $_->get_handle };

has '_copy_handle' => (
  isa       => 'sp_port',
  init_arg  => 'handle',
  coerce    => 1,
  # private methods
  reader    => '_get_copy_handle',
);

has '_name' => (
  isa       => 'Str',
  init_arg  => 'portname',
  # private methods
  reader    => '_get_name',
);

##
#
# extends accessor methods
#
##

# We provide 'port' as an alternate init_arg for '_copy_handle'

around BUILDARGS => sub {
  my $orig = shift;
  my $self = shift;
  my %args = ref $_[0] ? %{shift()} : @_;

  if (exists $args{port}) {
    $args{handle} = delete $args{port};
  }
  $self->$orig(%args);
};
  
# The order of processing the parameters by "trigger" can not be guaranteed.
# "after 'set_ ..." and "BUILD" are used to process the arguments in the correct order.

before 'set_baudrate' => sub {
  my ($self, $arg) = @_;
  $self->{baudrate} = $self->_trigger_baudrate($arg);
};

before 'set_bits' => sub {
  my ($self, $arg) = @_;
  $self->{bits} = $self->_trigger_bits($arg);
};

before 'set_parity' => sub {
  my ($self, $arg) = @_;
  $self->{parity} = $self->_trigger_parity($arg);
};

before 'set_stopbits' => sub {
  my ($self, $arg) = @_;
  $self->{stopbits} = $self->_trigger_stopbits($arg);
};

before 'set_rts' => sub {
  my ($self, $arg) = @_;
  $self->{rts} = $self->_trigger_rts($arg);
};

before 'set_cts' => sub {
  my ($self, $arg) = @_;
  $self->{cts} = $self->_trigger_cts($arg);
};

before 'set_dtr' => sub {
  my ($self, $arg) = @_;
  $self->{dtr} = $self->_trigger_dtr($arg);
};

before 'set_dsr' => sub {
  my ($self, $arg) = @_;
  $self->{dsr} = $self->_trigger_dsr($arg);
};

before 'set_xon_xoff' => sub {
  my ($self, $arg) = @_;
  $self->{xon_xoff} = $self->_trigger_xon_xoff($arg);
};

before 'set_flowcontrol' => sub {
  my ($self, $arg) = @_;
  $self->{flowcontrol} = $self->_trigger_flowcontrol($arg);
};

##
#
# extends default methods
#
##

sub BUILD {
  my $self = shift;

  # initialize the port first ..
  if ($self->_get_copy_handle) {
    $self->{port_handle} = $self->_build_copy_port
      or croak $ERRNO;
  } elsif (defined $self->_get_name) {
    $self->{port_handle} = $self->_build_port_by_name
      or croak $ERRNO;
  } else {
    croak 'Attribute (port|portname) is required';
  }
  # we don't need the helper attributes anymore
  delete $self->{_copy_handle}  if $self->_get_copy_handle;
  delete $self->{_name}         if $self->_get_name;

  # .. next open the port
  if (defined $self->{mode}) {
    my $ret_val = $self->_open_port($self->get_mode);
    defined ($ret_val)
      or croak $ERRNO;
    $self->{is_open} = $ret_val ? 1 : 0;
  }

  # .. now configure the port if opened
  foreach my $key ( qw(baudrate bits parity stopbits rts cts dtr dsr xon_xoff flowcontrol) ) {
    next unless defined $self->{$key};
    $self->is_open or croak "Attribute (mode) is required if using ($key)";
    my $value = $self->{$key};
    SWITCH: for ($key) {
      /^baudrate$/    && do { defined $self->_set_baudrate($value)    or croak $ERRNO; last SWITCH };
      /^bits$/        && do { defined $self->_set_bits($value)        or croak $ERRNO; last SWITCH };
      /^parity$/      && do { defined $self->_set_parity($value)      or croak $ERRNO; last SWITCH };
      /^stopbits$/    && do { defined $self->_set_stopbits($value)    or croak $ERRNO; last SWITCH };
      /^rts$/         && do { defined $self->_set_rts($value)         or croak $ERRNO; last SWITCH };
      /^cts$/         && do { defined $self->_set_cts($value)         or croak $ERRNO; last SWITCH };
      /^dtr$/         && do { defined $self->_set_dtr($value)         or croak $ERRNO; last SWITCH };
      /^dsr$/         && do { defined $self->_set_dsr($value)         or croak $ERRNO; last SWITCH };
      /^xon_xoff$/    && do { defined $self->_set_xon_xoff($value)    or croak $ERRNO; last SWITCH };
      /^flowcontrol$/ && do { defined $self->_set_flowcontrol($value) or croak $ERRNO; last SWITCH };
    }
  }
}

sub DEMOLISH {
  my $self = shift;
  $self->_close_port if $self->is_open;
  $self->_free_port if $self->get_handle;
}

##
#
# additional public methods
#
##

sub open {
  my $self = shift;
  my ($mode) = pos_validated_list( \@_,
    { isa => 'sp_mode' },
  );
  $self->{mode} = $mode;
  my $ret_val = $self->_open_port($self->get_mode);
  $self->{is_open} = $ret_val ? 1 : 0;
  defined ($ret_val)
    or return undef;
  return $self->is_open;
}

sub close {
  my $self = shift;
  my $ret_val = $self->_close_port;
  $self->{is_open} = 0;
  return $ret_val;
}

sub is_native {
  my $ret_val = shift->get_transport;
  defined ($ret_val)
    or return undef;
  return $ret_val == SP_TRANSPORT_NATIVE;
}

sub is_usb {
  my $ret_val = shift->get_transport;
  defined ($ret_val)
    or return undef;
  return $ret_val == SP_TRANSPORT_USB;
}

sub is_bluetooth {
  my $ret_val = shift->get_transport;
  defined ($ret_val)
    or return undef;
  return $ret_val == SP_TRANSPORT_BLUETOOTH;
}

sub get_usb {
  my $self = shift;
  return qw(-bus -address -vid -pid -manufacturer -product -serial) unless @_;
  my @options = @_;
  s/^\b/\-/ for @options; # option => -option
  my @ret_list = ();
  foreach (@options) {
    my $ret_val;
    SWITCH: {
      /^-bus$/          && do { $ret_val = $self->get_usb_bus;          last SWITCH };
      /^-address$/      && do { $ret_val = $self->get_usb_address;      last SWITCH };
      /^-vid$/          && do { $ret_val = $self->get_usb_vid;          last SWITCH };
      /^-pid$/          && do { $ret_val = $self->get_usb_pid;          last SWITCH };
      /^-pid$/          && do { $ret_val = $self->get_usb_pid;          last SWITCH };
      /^-manufacturer$/ && do { $ret_val = $self->get_usb_manufacturer; last SWITCH };
      /^-product$/      && do { $ret_val = $self->get_usb_product;      last SWITCH };
      /^-serial$/       && do { $ret_val = $self->get_usb_serial;       last SWITCH };
      {
        croak "Validation failed for 'option' with value $_ " .
              "(-bus|-address|-vid|-pid|-manufacturer|-product|-serial) is required";
      }
    }
    defined ($ret_val)
      or return undef;
    push @ret_list, $ret_val;
  }
  return @ret_list;
}

sub cget {
  my $self = shift;
  defined ($self->_read_settings)
    or return undef;
  return $self->config->cget(@_)
}

sub configure {
  my $self = shift;
  defined ($self->_read_settings)
    or return undef;
  return $self->config->configure(@_);
}

sub write_settings {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not assigned to a open port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_config($self->get_handle, $self->config->get_handle);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return 1;
};

sub blocking_read {
  my $self = shift;
  my ($count, $timeout) = pos_validated_list( \@_,
    { isa => 'size_t'       },
    { isa => 'unsigned_int' },
  );
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->get_mode & SP_MODE_READ) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_buf = '\0' x $count;
  my $ret_val = sp_blocking_read($self->get_handle, \$ret_buf, $count, $timeout);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val, $ret_buf;
}

sub blocking_read_next {
  my $self = shift;
  my ($count, $timeout) = pos_validated_list( \@_,
    { isa => 'size_t'       },
    { isa => 'unsigned_int' },
  );
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->get_mode & SP_MODE_READ) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_buf = '\0' x $count;
  my $ret_val = sp_blocking_read_next($self->get_handle, \$ret_buf, $count, $timeout);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val, $ret_buf;
}

sub nonblocking_read {
  my $self = shift;
  my ($count) = pos_validated_list( \@_,
    { isa => 'size_t' },
  );
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->get_mode & SP_MODE_READ) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_buf = '\0' x $count;
  my $ret_val = sp_nonblocking_read($self->get_handle, \$ret_buf, $count);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val, $ret_buf;
}

sub blocking_write {
  my $self = shift;
  # we create a scalar reference for the buffer argument to save a string copy
  my ($buf, $count, $timeout) = pos_validated_list( [\shift, @_],
    { isa => 'ScalarRef[Str]' },
    { isa => 'size_t'         },
    { isa => 'unsigned_int'   },
  );
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->get_mode & SP_MODE_WRITE) {
    # An attempt is made to write to a port that is not open for reading by any process.
    SET_ERROR(EPIPE); # Broken pipe
    return undef;
  }
  my $ret_val = sp_blocking_write($self->get_handle, $$buf, $count, $timeout);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val;
}

sub nonblocking_write {
  my $self = shift;
  # we create a scalar reference for the buffer argument to save a string copy
  my ($buf, $count) = pos_validated_list( [\shift, @_],
    { isa => 'ScalarRef[Str]' },
    { isa => 'size_t'         },
  );
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->get_mode & SP_MODE_WRITE) {
    # An attempt is made to write to a port that is not open for reading by any process.
    SET_ERROR(EPIPE); # Broken pipe
    return undef;
  }
  my $ret_val = sp_nonblocking_write($self->get_handle, $$buf, $count);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val;
}

sub input_waiting {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_val = sp_input_waiting($self->get_handle);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val;
}

sub output_waiting {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_val = sp_output_waiting($self->get_handle);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val;
}

sub drain {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_drain($self->get_handle);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return 1;
}

sub start_break {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_start_break($self->get_handle);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return 1;
}

sub end_break {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_end_break($self->get_handle);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return 1;
}

##
#
# private build methods
#
##

sub _build_port_by_name {
  my $self = shift;
  unless (defined $self->{_name}) {
    # The value does not name an existing port or value is an empty string.
    SET_ERROR(ENOENT); # No such file or directory
    return 0;
  }
  my $ret_val;
  my $ret_code = sp_get_port_by_name($self->_get_name, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return 0;
  }
  unless ($ret_val > 0) {
    # The value provided for the handle is not positive.
    SET_ERROR(EBADF); # Bad file descriptor
    return 0;
  }
  return $ret_val;
}

sub _build_copy_port {
  my $self = shift;
  unless (defined $self->{_copy_handle}) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENXIO); # No such device or address
    return 0;
  }
  my $ret_val;
  my $ret_code = sp_copy_port($self->_get_copy_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return 0;
  }
  unless ($ret_val > 0) {
    # The value provided for the handle is not positive.
    SET_ERROR(EBADF); # Bad file descriptor
    return 0;
  }
  return $ret_val;
}

sub _build_name {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_val = sp_get_port_name($self->get_handle);
  unless ($ret_val) {
    # The value does not name an existing port or value is an empty string.
    SET_ERROR(ENOENT); # No such file or directory
    return undef;
  }
  return $ret_val;
}

sub _build_description {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_val = sp_get_port_description($self->get_handle);
  unless ($ret_val) {
    # The value does not name an existing port or value is an empty string.
    SET_ERROR(ENOENT); # No such file or directory
    return undef;
  }
  return $ret_val;
}

sub _build_config {
  return Sigrok::SerialPort::Port::Config->new;
}

sub _build_transport {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_val = sp_get_port_transport($self->get_handle);
  unless ($ret_val >= 0) {
    SET_ERROR($ret_val);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_bus {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_usb) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val;
  my $ret_code = sp_get_port_usb_bus_address($self->get_handle, \$ret_val, \$_);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_address {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_usb) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val;
  my $ret_code = sp_get_port_usb_bus_address($self->get_handle, \$_, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_vid {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_usb) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val;
  my $ret_code = sp_get_port_usb_vid_pid($self->get_handle, \$ret_val, \$_);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_pid {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_usb) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val;
  my $ret_code = sp_get_port_usb_vid_pid($self->get_handle, \$_, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_manufacturer {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_usb) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val = sp_get_port_usb_manufacturer($self->get_handle);
  unless ($ret_val) {
    # The value does not name an existing port or value is an empty string.
    SET_ERROR(ENOENT); # No such file or directory
    return undef;
  }
  return $ret_val;
}

sub _build_usb_product {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_usb) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val = sp_get_port_usb_product($self->get_handle);
  unless ($ret_val) {
    # The value does not name an existing port or value is an empty string.
    SET_ERROR(ENOENT); # No such file or directory
    return undef;
  }
  return $ret_val;
}

sub _build_usb_serial {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_usb) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val = sp_get_port_usb_serial($self->get_handle);
  unless ($ret_val) {
    # The value does not name an existing port or value is an empty string.
    SET_ERROR(ENOENT); # No such file or directory
    return undef;
  }
  return $ret_val;
}

sub _build_bluetooth_address {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_bluetooth) {
    # A request was made of a nonexistent device, or the request was outside the capabilities of the device.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  my $ret_val = sp_get_port_bluetooth_address($self->get_handle);
  unless ($ret_val) {
    # The value does not name an existing port or value is an empty string.
    SET_ERROR(ENODEV); # No such device
    return undef;
  }
  return $ret_val;
}

sub _build_native_handle {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_val;
  my $ret_code = sp_get_port_handle($self->get_handle, \$ret_val);  
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $ret_val;
}

sub _build_signals {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_val;
  my $ret_code = sp_get_signals($self->get_handle, \$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_baudrate($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_bits($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_parity($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_stopbits($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_rts($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_cts($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_dtr($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_dsr($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_xon_xoff($self->get_handle, $new);
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
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_set_flowcontrol($self->get_handle, $new);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return $new;
}

sub _trigger_flush {
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'sp_buffer' },
    { isa => 'sp_buffer', optional => 1 },
  );
  unless ($self->get_handle) {
    # The file descriptor underlying stream is not valid.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # An attempt is made to write to a port that is not open for reading by any process.
    SET_ERROR(EPIPE); # Broken pipe
    return undef;
  }
  my $ret_code = sp_set_flowcontrol($self->get_handle, $new);
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

sub _free_port {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  sp_free_port($self->get_handle);
  return 1;
}

sub _open_port {
  my $self = shift;
  my ($mode) = pos_validated_list( \@_,
    { isa => 'sp_mode' },
  );
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_open($self->get_handle, $mode);
  unless ($ret_code == SP_OK) {
    # A signal was caught during open
    SET_ERROR(EINTR); # Interrupted function call
    return undef;
  }
  return 1;
}

sub _close_port {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not assigned to a open port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_close($self->get_handle);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return 1;
}

sub _read_settings {
  my $self = shift;
  unless ($self->get_handle) {
    # The handle argument is not a valid port descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  unless ($self->is_open) {
    # The handle argument is not a valid descriptor open for reading.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  my $ret_code = sp_get_config($self->get_handle, $self->config->get_handle);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return 1;
};

no Moose;
__PACKAGE__->meta->make_immutable;

1;
