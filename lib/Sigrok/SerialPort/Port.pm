package Sigrok::SerialPort::Port;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate;
use Carp qw( croak );
use English qw( -no_match_vars );
use Errno qw( :POSIX );

use Sigrok::SerialPort qw(
  SP_OK

  SP_MODE_READ
  SP_MODE_WRITE
  
  SP_TRANSPORT_NATIVE
  SP_TRANSPORT_USB
  SP_TRANSPORT_BLUETOOTH

  SP_SIG_CTS
  SP_SIG_DSR
  SP_SIG_DCD
  SP_SIG_RI
  
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
  
after 'config' => sub {
  shift->_get_config unless $#_;
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
  # remove undefined keys from a hash
  delete @$self{ grep { not defined $self->{$_} } keys %$self };

  # initialize the port first ..
  if (defined $self->{_copy_handle}) {
    $self->{port_handle} = $self->_build_copy_port
      or croak $ERRNO;
  } elsif (defined $self->{_name}) {
    $self->{port_handle} = $self->_build_port_by_name
      or croak $ERRNO;
  } else {
    croak 'Attribute (port|portname) is required';
  }
  # we don't need the helper attributes anymore
  delete $self->{_copy_handle}  if defined $self->{_copy_handle};
  delete $self->{_name}         if defined $self->{_name};

  # .. next open the port
  if (defined $self->{mode}) {
    my $ret_val = $self->_open_port($self->get_mode);
    defined ($ret_val)
      or croak $ERRNO;
    $self->{is_open} = $ret_val ? 1 : 0;
  }

  # .. now configure the port if opened
  foreach my $key ( qw/baudrate bits parity stopbits rts cts dtr dsr xon_xoff flowcontrol/ ) {
    next unless exists $self->{$key};
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
  unless (@_) {
    my @ret_val = qw(-bus -address -vid -pid -manufacturer -product -serial);
    return wantarray ? @ret_val : $self->is_usb;
  }
  my @options = @_;
  s/^\b/\-/ for @options; # option => -option
  my @ret_list = ();
  my $cnt = 0;
  foreach (@options) {
    my $ret_val;
    SWITCH: {
      /^-bus$/          && do { $ret_val = $self->get_usb_bus;          last SWITCH };
      /^-address$/      && do { $ret_val = $self->get_usb_address;      last SWITCH };
      /^-vid$/          && do { $ret_val = $self->get_usb_vid;          last SWITCH };
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
    $cnt++
  }
  return wantarray ? @ret_list : $cnt;
}

sub cget {
  # we use the getter method here to read the config.
  my $config = shift->config;
  defined $config
    or return undef;
  return $config->cget(@_);
}

sub configure {
  # we use the getter method here to read the config.
  my $config = shift->config;
  defined $config
    or return undef;
  return $config->configure(@_);
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
  unless ($self->has_config) {
    # The handle argument has not a valid config descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  # we can not use the getter method here, otherwise we will re-read the config
  my $config = $self->{config}; 
  my $ret_code = sp_set_config($self->get_handle, $config->get_handle);
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

sub get_cts {
  my $signal = shift->get_signal;
  defined $signal
    or return undef;
  return $signal & SP_SIG_CTS ? 1 : 0;
}

sub get_dsr {
  my $signal = shift->get_signal;
  defined $signal
    or return undef;
  return $signal & SP_SIG_DSR ? 1 : 0;
}

sub get_rlsd {
  my $signal = shift->get_signal;
  defined $signal
    or return undef;
  return $signal & SP_SIG_DCD ? 1 : 0;
}

sub get_ring {
  my $signal = shift->get_signal;
  defined $signal
    or return undef;
  return $signal & SP_SIG_RI ? 1 : 0;
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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
    # The handle argument is not assigned to a open port descriptor.
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

sub _get_config {
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
  unless ($self->has_config) {
    # The handle argument has not a valid config descriptor.
    SET_ERROR(EBADF); # Bad file descriptor
    return undef;
  }
  # we can not use the getter method here, otherwise we'll create an infinite loop
  my $config = $self->{config};
  my $ret_code = sp_get_config($self->get_handle, $config->get_handle);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  return 1;
};

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sigrok::SerialPort::Config - represents a serial port.

=head1 SYNOPSIS

  use Sigrok::SerialPort::Port;
  use constant COUNT    => 128;
  use constant TIMEOUT  => 500;
  
  my $port = Sigrok::SerialPort::Port->new(portname => 'COM3');
  $port->open(SP_MODE_READ_WRITE);
  $port->configure(
    '-baudrate'  => 9600,
    '-bits'      => 8,
    '-parity'    => SP_PARITY_NONE,
    '-stop_bits' => 1,
  );
  $port->write_settings;
  my ($num, $buf) = $port->blocking_read(COUNT, TIMEOUT);
  while ($num > 0) {
    ...
  }
  $port->close();

=head1 DESCRIPTION

Sigrok::SerialPort::Port is a OOP module designed to abstract the backend
library of the external libserialport API.

It is meant as an alternative to Sigrok::SerialPort and the C based API, with
increased ease-of-use, an enhanced support for memory handling, and the ability
to handle multiple ports in a perl'ish way.

=head2 EXPORT

=head3 Port enumeration

=over 12

=item C<< new(port|portname => $port) >>

=item C<< new(port|portname => $port, mode => $modeI<< , option => value,
option => value, ... >>) >>

The constructor C<new> return a new serial port object. The constructor
internally allocates an structure of type C<sp_port>. 

  $port = Sigrok::SerialPort::Port->new(portname => 'COM3');

If required, I<< option => value >> pairs can be passed by the constructor to
pre-configure the serial port. Please note, if at least one C<option> is
specified, the parameter C<mode> is required.

  # open COM3 for read/write and set 9600,8,N,1
  $port = Sigrok::SerialPort::Port->new(
    portname  => 'COM3',
    mode      => SP_MODE_READ_WRITE,
    baudrate  => 9600,
    bits      => 8,
    parity    => SP_PARITY_NONE,
    stop_bits => 1,
  );

=back

=head3 Port handling

=over 12

=item C<open($mode)>

Open the serial port object. The parameter C<$mode> is to use when opening the
serial port. C<$mode> has the type C<sp_mode>: C<SP_MODE_...>

  $port->open(SP_MODE_READ_WRITE) || die $!;

If an error occurs, C<undef> is returned.

=item C<is_open()>

Returns true (C<1>) if the serial port is open; otherwise, false C<0>.
The default is false C<0>.

  if ($port->is_open) {
    # do something
  }

The return value is C<undef> if an error occurs.

=item C<close()>

Close the serial port object.

  $port->close() || die $!;

=item C<get_description>

Get a description for a port, to present to end user.

  print 'Description: ', $port->get_description, "\n";

The return value is C<undef> if an error occurs.

=item C<get_transport>

Get the transport type C<sp_transport> used by a port.

  if ($port->get_transport == SP_TRANSPORT_USB) {
    print 'USB bus: ',  $port->get_usb('-bus'),     "\n";
    print 'USB addr: ', $port->get_usb('-address'), "\n";
  }

The return value is C<undef> if an error occurs.

=item C<is_native>

=item C<is_usb>

=item C<is_bluetooth>

Alias for C<get_transport == SP_TRANSPORT_...>.

  # $transp = $port->get_transport == SP_TRANSPORT_NATIVE ? 1 : 0;
  $transp = $port->is_native;
  # $transp = $port->get_transport == SP_TRANSPORT_USB ? 1 : 0;
  $transp = $port->is_usb;
  # $transp = $port->get_transport == SP_TRANSPORT_BLUETOOTH ? 1 : 0;
  $transp = $port->is_bluetooth;

=item C<< @list = get_usb('-option'I<< , '-option', ... >>) >>

=item C<< $scalar = get_usb('-option'I<< , '-option', ... >>) >>

Gets the values of each I<'-option'>. Valid options are C<-bus, -address, -vid,
-pid, -manufacturer, -product, -serial>. The C<'> character is necessary due to
perl's parsing rules.

  @usb_info = $port->get_usb('-bus', '-address', '-vid', '-pid') or die $!;
  print 'USB info: ' join(', ', @usb_info), "\n";

In the list context, all options are returned. In scalar context, the number of
options is returned. If an error occurs, C<undef> is returned.

=item C<@list = get_usb()>

=item C<$scalar = get_usb()>

In the list context, all valid options are returned. The scalar context returns
whether USB is being used. If an error occurs, C<undef> is returned.

  print 'serial port ', scalar $port->get_usb ? '' : 'not', " via USB\n";
  print "valid options are: \n";
  print join "\n", $port->get_usb;

=item C<get_usb_bus>

=item C<get_usb_address>

=item C<get_usb_vid>

=item C<get_usb_pid>

=item C<get_usb_manufacturer>

=item C<get_usb_product>

=item C<get_usb_serial>

Standard USB get methods. Alias for C<usb_get('-option'I<, '-option', ...>)>.

  # ($bus, $address) = $port->usb_get('-bus', '-address') || die $!;
  $bus      = $port->get_bus()      || die $!;
  $address  = $port->get_address()  || die $!;

The USB get methods returned C<undef> if an error occurs.

=item C<get_bluetooth_address>

Get the MAC address of a Bluetooth serial adapter port. The port MAC address,
or C<undef> if an invalid port is passed. 

=item C<get_handle()>

C<get_handle> gives you access to the internal structure of type C<sp_port>. 
The assigned internal structure is automatically created by the C<new>
constructor and freeded by the destructor.

  $handle = $port->get_handle() || die $!;

The handle can be used for direct libserialport API calls to the
C<Sigrok::SerialPort> backend library.

If any error is occurred, the returned value is C<undef>. Otherwise, the handle
of type C<sp_port> is returned by the libserialport backend.

=item C<get_native_handle>

Get the operating system handle for a port. To obtain a valid handle, the port
must first be opened by calling C<open(...)>. After the port is closed or the port
object ist destroyed, the handle may no longer be valid.

  $os_handle = $port->get_native_handle() || die $!;

This feature is provided so that programs may make use of OS-specific
functionality where desired. Doing so obviously comes at a cost in portability.
It also cannot be guaranteed that direct usage of the OS handle will not
conflict with the library's own usage of the port. Be careful.

If any error is occurred, the returned value is C<undef>. Otherwise, it will be
point to the OS handle.

=back

=head3 Configuration

=over 12

=item C<< @list = configure('-option' => valueI<< , '-option' => value,
... >>) >>

=item C<< $scalar = configure('-option' => valueI<< , '-option' => value,
... >>) >>

Sets the values of I<-option> to I<value> for each I<< '-option' => value >>
pair. Valid options are C<-baudrate, -bits, -parity, -stopbits, -rts, -cts,
-dtr, -dsr, -xon_xoff, -flowcontrol>. The C<'> character is necessary due to
perl's parsing rules.

  $port->configure(
    '-baudrate'  => 9600,
    '-bits'      => 8,
    '-parity'    => SP_PARITY_NONE,
    '-stop_bits' => 1,
  ) or die $!;
  $port->write_settings || die $!;

In the list context, all applied values of the options are returned. In scalar
context, the number of options is returned. If an error occurs, C<undef> is
returned.

Please note that the C<configure> method does not implicit apply the options to
a serial port. This must be done by the L</write_settings()> method.

=item C<@list = configure()>

=item C<$scalar = configure()>

In the list context, all valid options are returned. In scalar context, the
number of options is returned. If an error occurs, C<undef> is returned.

  print 'configure returns ', scalar $port->configure, " number of options.\n";
  print "valid options are: \n";
  print join "\n", $port->configure;

=item C<cget('-options')>

The C<cget> method read all options from the serial port and returns the current
value of C<-option>. C<cget> returned C<undef> if an error occurs. 

  $baud = $port->cget('-baudrate') || die $!;

Valid options are C<-baudrate, -bits, -parity, -stopbits, -rts, -cts, -dtr,
-dsr, -xon_xoff>. The C<'> character is necessary due to perl's parsing rules.

=item C<config()>

Get the current configuration of the serial port object.

The port object allocate a configuration object using
C<Sigrok::SerialPort::Config::new()> and pass this as the config attribute.
The configuration object will be updated with the port configuration.

Any parameters that are configured with settings not recognised or supported by
the library, will be set to special values (-1) that are ignored by
C<write_setttings()>.

The method returned the configuration object upon success, or C<undef> if an
error occurs.
 
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

Standard set methods. If you want to set more than one option, use
C</configure(...)>.

  $port->set_baudrate(9600) || die $!;
  $port->set_bits(8)        || die $!;
  # $port->configure('-baudrate' => 9600, '-bits' => 8) || die $!;

The set methods return the specified value or C<undef> if an error occurs.

=item C<write_settings()>

Set the configuration for the serial port object. For each parameter in the
configuration, there is a special value (-1). These values will be ignored and
the corresponding setting left unchanged on the port.

  $port->configure('-baudrate'  => 9600) || die $!;
  $port->write_settings || die $!;

=back

=head3 Data handling

=over 12

=item C<($num, $buf) = blocking_read($count, $timeout_ms)>

Read bytes from the serial port, blocking until complete. C<$count> specifies
the requested number of bytes to read. C<$timeout_ms> specifies the timeout in
milliseconds, or zero to wait indefinitely.

First returned parameter represents the number of bytes read on success, or
C<undef> if an error occurs. If the number of bytes returned is less than that
requested, the timeout was reached before the requested number of bytes was
available. The second returned parameter contains a string that stores the bytes
read (C<packed>).

If C<$timeout_ms> is zero, the function will always return either the requested
number or C<undef> if an error occurs. 

=item C<($num, $buf) = blocking_read_next($count, $timeout_ms)>

Read bytes from the serial port, returning as soon as any data is available.
C<$count> specifies the maximum number of bytes to read. C<$timeout_ms>
specifies the timeout in milliseconds, or zero to wait indefinitely. 

First returned parameter represents the number of bytes read on success, or
C<undef> if an error occurs. If the result is zero, the timeout was reached
before any bytes were available. The second returned parameter contains a string
that stores the bytes read (C<packed>).

If C<$timeout_ms> is zero, the function will always return either at least one
byte, or C<undef> if an error occurs.

=item C<($num, $buf) = nonblocking_read($count)>

Read bytes from the serial port, without blocking. C<$count> specifies the
maximum number of bytes to read.

First returned parameter represents the number of bytes read on success, or
C<undef> if an error occurs. The number of bytes returned may be any number
from zero to the maximum that was requested. The second returned parameter
contains a string that stores the bytes read (C<packed>).

=item C<$num = blocking_write($buf, $count, $timeout);>

Write bytes to the serial port, blocking until complete. <$buf> specifies a
string containing as C<packed> bytes to write. C<$count> specifies the
requested number of bytes to write. C<$timeout_ms> specifies the timeout in
milliseconds, or zero to wait indefinitely.

Returned the number of bytes written on success, or C<undef> if an error occurs.
If the number of bytes returned is less than requested, the timeout was reached
before the requested number of bytes was written. If timeout is zero, the
function will always return either the requested number of bytes or C<undef> if
an error occurs. In the event of an error there is no way to determine how many
bytes were sent before the error occurred.

=item C<$num = nonblocking_write($buf, $count);>

Write bytes to the serial port object, without blocking. <$buf> specifies a
string containing as C<packed> bytes to write. C<$count> specifies the
requested number of bytes to write.

Returned the number of bytes written on success, or C<undef> if an error occurs.
The number of bytes returned may be any number from zero to the  maximum that
was requested.

To check whether all written bytes have actually been transmitted, use the
L</output_waiting()> method. To wait until all written bytes have actually been
transmitted, use the L</drain()> method.

=item C<input_waiting()>

Gets the number of bytes waiting in the input buffer.

Returned the number of bytes waiting on success, or C<undef> if an error occurs.

=item C<output_waiting()>

Gets the number of bytes waiting in the output buffer.

Returned the number of bytes waiting on success, or C<undef> if an error occurs.

=item C<flush($buffer)>

Flush serial port buffers. Data in the selected buffer(s) is discarded.

Returned C<undef> if an error occurs.

=item C<drain()>

Wait for buffered data to be transmitted.

Returned C<undef> if an error occurs.

=back

=head3 Signals

=over 12

=item C<get_cts()>

The method returns true (1) if the I<Clear To Send> (CTS) is detected;
otherwise, false (0). Alias for C<defined(get_signals & SP_SIG_CTS)>.

  print 'Clear To Send: ', $port->get_cts ? "on\n" : "off\n";

=item C<get_dsr()>

The method returns true (1) if the I<Data Set Ready> (DSR) is detected;
otherwise, false (0). Alias for C<defined(get_signals & SP_SIG_DSR)>.

  print 'Data Set Ready: ', $port->get_dsr ? "on\n" : "off\n";

=item C<get_rlsd()>

The method returns true (1) if the I<Carrier Detect> (CD/RLSD) is detected;
otherwise, false (0). Alias for C<defined(get_signals & SP_SIG_DCD)>.

  print 'Carrier Detect: ', $port->get_rlsd ? "on\n" : "off\n";

=item C<get_ring()>

A Ring Indicator (RING) indicator was detected. Alias for
C<defined(get_signals & SP_SIG_RI)>.

  print 'Ring Indicator: ', $port->get_ring ? "true\n" : "false\n";

=item C<get_signals()>

Gets the status of the control signals for the specified port. 

The result is a bitmask in which individual signals can be checked by bitwise
C<&> (AND) with constants C<SP_SIG_...>. If an error occurs, C<undef> is
returned.

    $signals = $port->get_signals || die $!;
    print 'CTS : ', $signals & SP_SIG_CTS ? "on\n" : "off\n";
    print 'DSR : ', $signals & SP_SIG_DSR ? "on\n" : "off\n";
    print 'CD  : ', $signals & SP_SIG_DCD ? "on\n" : "off\n";
    print 'RI  : ', $signals & SP_SIG_RI  ? "on\n" : "off\n";

=item C<start_break()>

Put the port transmit line into the break state.

Returned C<undef> if an error occurs.

=item C<end_break()>

Take the port transmit line out of the break state.

Returned C<undef> if an error occurs.

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
