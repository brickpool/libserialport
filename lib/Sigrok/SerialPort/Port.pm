package Sigrok::SerialPort::Port;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate;
use Carp qw( croak );

use Sigrok::SerialPort qw(
  SP_ERR_ARG
  SP_ERR_SUPP
  
  SP_TRANSPORT_NATIVE
  SP_TRANSPORT_USB
  SP_TRANSPORT_BLUETOOTH
);
use Sigrok::SerialPort::Backend qw(
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
  # private methods
  predicate => '_has_handle',
  writer    => '_set_handle',
);

##
#
# Port handling
#
##

has 'mode' => (
  isa       => 'sp_mode',
  reader    => 'get_mode',
  # private methods
  predicate => '_has_mode',
  writer    => '_set_mode',
);

has 'is_open' => (
  isa       => 'Bool',
  init_arg  => 'undef',
  default   => 0,
  reader    => 'is_open',
  # private methods
  writer    => '_set_as_open',
);

has 'name' => (
  isa       => 'Str',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_name',
  # private methods
  builder   => '_build_name',
);

has 'description' => (
  isa       => 'Str',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_description',
  # private methods
  builder   => '_build_description',
);

has 'transport' => (
  isa       => 'sp_transport',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_transport',
  # private methods
  builder   => '_build_transport',
);

has 'usb_bus' => (
  isa       => 'Int',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_bus',
  # private methods
  builder   => '_build_usb_bus',
);

has 'usb_address' => (
  isa       => 'Int',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_address',
  # private methods
  builder   => '_build_usb_address',
);

has 'usb_vid' => (
  isa       => 'Int',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_vid',
  # private methods
  builder   => '_build_usb_vid',
);

has 'usb_pid' => (
  isa       => 'Int',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_pid',
  # private methods
  builder   => '_build_usb_pid',
);

has 'usb_manufacturer' => (
  isa       => 'Str',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_manufacturer',
  # private methods
  builder   => '_build_usb_manufacturer',
);

has 'usb_product' => (
  isa       => 'Str',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_product',
  # private methods
  builder   => '_build_usb_product',
);

has 'usb_serial' => (
  isa       => 'Str',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_usb_serial',
  # private methods
  builder   => '_build_usb_serial',
);

has 'bluetooth_address' => (
  isa       => 'Str',
  lazy      => 1,
  init_arg  => 'undef',
  reader    => 'get_bluetooth_address',
  # private methods
  builder   => '_build_bluetooth_address',
);

has 'native_handle' => (
  isa       => 'Value',
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
  isa       => 'sp_baudrate',
  writer    => 'set_baudrate',
  # private methods
  predicate => '_has_baudrate',
  reader    => '_get_baudrate',
);

has 'bits' => (
  isa       => 'sp_databits',
  writer    => 'set_bits',
  # private methods
  predicate => '_has_bits',
  reader    => '_get_bits',
);

has 'parity' => (
  isa       => 'sp_parity',
  writer    => 'set_parity',
  # private methods
  predicate => '_has_parity',
  reader    => '_get_parity',
);

has 'stopbits' => (
  isa       => 'sp_stopbits',
  writer    => 'set_stopbits',
  # private methods
  predicate => '_has_stopbits',
  reader    => '_get_stopbits',
);

has 'rts' => (
  isa       => 'sp_rts',
  writer    => 'set_rts',
  # private methods
  predicate => '_has_rts',
  reader    => '_get_rts',
);

has 'cts' => (
  isa       => 'sp_cts',
  writer    => 'set_cts',
  # private methods
  predicate => '_has_cts',
  reader    => '_get_cts',
);

has 'dtr' => (
  isa       => 'sp_dtr',
  writer    => 'set_dtr',
  # private methods
  predicate => '_has_dtr',
  reader    => '_get_dtr',
);

has 'dsr' => (
  isa       => 'sp_dsr',
  writer    => 'set_dsr',
  # private methods
  predicate => '_has_dsr',
  reader    => '_get_dsr',
);

has 'xon_xoff' => (
  isa       => 'sp_xonxoff',
  writer    => 'set_xon_xoff',
  # private methods
  predicate => '_has_xon_xoff',
  reader    => '_get_xon_xoff',
);

has 'flowcontrol' => (
  isa       => 'sp_flowcontrol',
  writer    => 'set_flowcontrol',
  # private methods
  predicate => '_has_flowcontrol',
  reader    => '_get_flowcontrol',
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
);

##
#
# Signals
#
##

has 'signal_mask' => (
  isa       => 'sp_signal',
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
  clearer   => '_clear_copy_handle',
  predicate => '_has_copy_handle',
  reader    => '_get_copy_handle',
);

has '_name' => (
  isa       => 'Str',
  init_arg  => 'portname',
  # private methods
  clearer   => '_clear_name',
  predicate => '_has_name',
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

after 'set_baudrate' => sub {
  shift->_set_baudrate(@_);
};

after 'set_bits' => sub {
  shift->_set_bits(@_);
};

after 'set_parity' => sub {
  shift->_set_parity(@_);
};

after 'set_stopbits' => sub {
  shift->_set_stopbits(@_);
};

after 'set_rts' => sub {
  shift->_set_rts(@_);
};

after 'set_cts' => sub {
  shift->_set_cts(@_);
};

after 'set_dtr' => sub {
  shift->_set_dtr(@_);
};

after 'set_dsr' => sub {
  shift->_set_dsr(@_);
};

after 'set_xon_xoff' => sub {
  shift->_set_xon_xoff(@_);
};

after 'set_flowcontrol' => sub {
  shift->_set_flowcontrol(@_);
};

after 'flush' => sub {
  shift->_flush(@_);
};

##
#
# extends default methods
#
##

sub BUILD {
  my $self = shift;

  # initialize the port first ..
  my $handle;
  if ($self->_has_copy_handle) {
    $handle = $self->_build_copy_port;
  } elsif ($self->_has_name) {
    $handle = $self->_build_port_by_name;
  } else {
    croak 'Attribute (port|portname) is required';
  }
  $self->_set_handle($handle) if $self->is_ok && $handle;
  $self->_clear_copy_handle   if $self->_has_copy_handle;
  $self->_clear_name          if $self->_has_name;

  # .. next open the port
  if ($self->_has_mode) {
    $self->_open_port($self->get_mode);
    $self->_set_as_open($self->is_ok ? 1 : 0);
  }

  # .. configure the port if opened
  if (!! ( $self->_has_baudrate
      || $self->_has_bits
      || $self->_has_parity
      || $self->_has_stopbits
      || $self->_has_rts
      || $self->_has_cts
      || $self->_has_dtr
      || $self->_has_dsr
      || $self->_has_xon_xoff
      || $self->_has_flowcontrol )
    &&
      not $self->is_open
  ) {
    croak 'Attribute (mode) is required if using (baudrate|bits|parity|stopbits|rts|cts|dtr|dsr|xon_xoff|flowcontrol)'
  }

  $self->_set_baudrate    ( $self->_get_baudrate    ) if $self->_has_baudrate;
  $self->_set_bits        ( $self->_get_bits        ) if $self->_has_bits;
  $self->_set_parity      ( $self->_get_parity      ) if $self->_has_parity;
  $self->_set_stopbits    ( $self->_get_stopbits    ) if $self->_has_stopbits;
  $self->_set_rts         ( $self->_get_rts         ) if $self->_has_rts;
  $self->_set_cts         ( $self->_get_cts         ) if $self->_has_cts;
  $self->_set_dtr         ( $self->_get_dtr         ) if $self->_has_dtr;
  $self->_set_dsr         ( $self->_get_dsr         ) if $self->_has_dsr;
  $self->_set_xon_xoff    ( $self->_get_xon_xoff    ) if $self->_has_xon_xoff;
  $self->_set_flowcontrol ( $self->_get_flowcontrol ) if $self->_has_flowcontrol;
}

sub DEMOLISH {
  my $self = shift;
  $self->_close_port if $self->is_open;
  $self->_free_port if $self->_has_handle;
}

##
#
# additional public methods
#
##

sub open
{
  my $self = shift;
  my ($mode) = pos_validated_list( \@_,
    { isa => 'sp_mode' },
  );
  $self->_set_mode($mode);
  $self->_open_port($self->get_mode);
  $self->_set_as_open($self->is_ok ? 1 : 0);
  return $self->is_open ? 1 : 0;
}

sub close
{
  my $self = shift;
  $self->_close_port if $self->is_open;
  $self->_set_as_open(0);
}

sub is_native
{
  return shift->get_transport == SP_TRANSPORT_NATIVE;
}

sub is_usb
{
  return shift->get_transport == SP_TRANSPORT_USB;
}

sub is_bluetooth
{
  return shift->get_transport == SP_TRANSPORT_BLUETOOTH;
}

sub get_usb {
  my $self = shift;
  return qw('-bus' '-address' '-vid' '-pid' '-manufacturer' '-product' '-serial') unless @_;
  my @options = @_;
  my @ret_val = ();
  s/^\b/\-/ for @options; # option => -option
  foreach (@options) {
    if (/^-bus$/) {
      push @ret_val, $self->get_usb_bus;
      last unless $self->is_ok;
    }
    elsif (/^-address$/) {
      push @ret_val, $self->get_usb_address;
      last unless $self->is_ok;
    }
    elsif (/^-vid$/) {
      push @ret_val, $self->get_usb_vid;
      last unless $self->is_ok;
    }
    elsif (/^-pid$/) {
      push @ret_val, $self->get_usb_pid;
      last unless $self->is_ok;
    }
    elsif (/^-pid$/) {
      push @ret_val, $self->get_usb_pid;
      last unless $self->is_ok;
    }
    elsif (/^-manufacturer$/) {
      push @ret_val, $self->get_usb_manufacturer;
      last unless $self->is_ok;
    }
    elsif (/^-product$/) {
      push @ret_val, $self->get_usb_product;
      last unless $self->is_ok;
    }
    elsif (/^-serial$/) {
      push @ret_val, $self->get_usb_serial;
      last unless $self->is_ok;
    }
    else {
      croak "Validation failed for 'option' with value $_ " .
            "(-bus|-address|-vid|-pid|-manufacturer|-product|-serial) is required";
      $self->SET_ERROR(SP_ERR_ARG, 'Invalid Argument');
      return undef;
    }
  }
  return @ret_val;
}

sub cget
{
  my $self = shift;
  my $ret_val;

  $self->RETURN_OK;
  $self->_read_config;
  $ret_val = $self->config->cget(@_) if $self->is_ok;
  $self->RETURN_INT($self->config->return_code) if $self->is_ok;
  return $self->is_ok ? $ret_val : undef;
}

sub configure
{
  my $self = shift;
  return qw('-baudrate' '-bits' '-parity' '-stopbits' '-rts' '-cts' '-dtr' '-dsr' '-xon_xoff') unless @_;
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
  $self->RETURN_OK;
  my $ret_val;
  $self->_read_config;
  $ret_val = $self->config->configure(%options) if $self->is_ok;
  $self->RETURN_INT($self->config->return_code) if $self->is_ok;
  $self->_apply_config if $self->is_ok;
  return $self->is_ok ? $ret_val : undef;
}

sub blocking_read
{
  my $self = shift;
  my ($count, $timeout) = pos_validated_list( \@_,
    { isa => 'size_t'       },
    { isa => 'unsigned_int' },
  );
  unless ($self->_has_handle) {
    return
      $self->RETURN_FAIL('Undefined port'),
      undef;
  }
  my $ret_buf = '\0' x $count;
  my $ret_val = $self->RETURN_INT(sp_blocking_read($self->get_handle, \$ret_buf, $count, $timeout));
  unless ($self->is_ok) {
    return
      $self->RETURN_ERROR($self->return_code, $self->last_error_message),
      undef;
  }
  return $ret_val, $ret_buf;
}

sub blocking_read_next
{
  my $self = shift;
  my ($count, $timeout) = pos_validated_list( \@_,
    { isa => 'size_t'       },
    { isa => 'unsigned_int' },
  );
  unless ($self->_has_handle) {
    return
      $self->RETURN_FAIL('Undefined port'),
      undef;
  }
  my $ret_buf = '\0' x $count;
  my $ret_val = $self->RETURN_INT(sp_blocking_read_next($self->get_handle, \$ret_buf, $count, $timeout));
  unless ($self->is_ok) {
    return
      $self->RETURN_ERROR($self->return_code, $self->last_error_message),
      undef;
  }
  return $ret_val, $ret_buf;
}

sub nonblocking_read
{
  my $self = shift;
  my ($count) = pos_validated_list( \@_,
    { isa => 'size_t' },
  );
  unless ($self->_has_handle) {
    return
      $self->RETURN_FAIL('Undefined port'),
      undef;
  }
  my $ret_buf = '\0' x $count;
  my $ret_val = $self->RETURN_INT(sp_nonblocking_read($self->get_handle, \$ret_buf, $count));
  unless ($self->is_ok) {
    return
      $self->RETURN_ERROR($self->return_code, $self->last_error_message),
      undef;
  }
  return $ret_val, $ret_buf;
}

sub blocking_write
{
  my $self = shift;
  my ($buf, $count, $timeout) = pos_validated_list( \@_,
    { isa => 'Str'          },
    { isa => 'size_t'       },
    { isa => 'unsigned_int' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port'),
    return undef;
  }
  $self->RETURN_INT(sp_blocking_write($self->get_handle, $buf, $count, $timeout));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return 1;
}

sub nonblocking_write
{
  my $self = shift;
  my ($buf, $count) = pos_validated_list( \@_,
    { isa => 'Str'    },
    { isa => 'size_t' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port'),
    return undef;
  }
  $self->RETURN_INT(sp_nonblocking_write($self->get_handle, $buf, $count));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return 1;
}

sub input_waiting
{
  my $self = shift;
  unless ($self->_has_handle) {
    return $self->RETURN_FAIL('Undefined port');
  }
  my $ret_val = $self->RETURN_INT(sp_input_waiting($self->get_handle));
  unless ($self->is_ok) {
    return $self->RETURN_ERROR($self->return_code, $self->last_error_message);
  }
  return $ret_val;
}

sub output_waiting
{
  my $self = shift;
  unless ($self->_has_handle) {
    return $self->RETURN_FAIL('Undefined port');
  }
  my $ret_val = $self->RETURN_INT(sp_output_waiting($self->get_handle));
  unless ($self->is_ok) {
    return $self->RETURN_ERROR($self->return_code, $self->last_error_message);
  }
  return $ret_val;
}

sub drain {
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_INT(sp_drain($self->get_handle));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return 1;
}

sub start_break
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_INT(sp_start_break($self->get_handle));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return 1;
}

sub end_break
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_INT(sp_end_break($self->get_handle));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return 1;
}

##
#
# private build methods
#
##

sub _build_port_by_name
{
  my $self = shift;
  unless ($self->_has_name) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  my $ret_val;
  $self->RETURN_INT(sp_get_port_by_name($self->_get_name, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result');
    return undef;
  }
  return $ret_val;
}

sub _build_copy_port
{
  my $self = shift;
  unless ($self->_has_copy_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  my $ret_val;
  $self->RETURN_INT(sp_copy_port($self->_get_copy_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result');
    return undef;
  }
  return $ret_val;
}

sub _build_name
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_OK;
  my $ret_val = sp_get_port_name($self->get_handle);
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result string');
    return undef;
  }
  return $ret_val;
}

sub _build_description
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_OK;
  my $ret_val = sp_get_port_description($self->get_handle);
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result string');
    return undef;
  }
  return $ret_val;
}

sub _build_config {
  return Sigrok::SerialPort::Port::Config->new;
}

sub _build_transport
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_OK;
  return sp_get_port_transport($self->get_handle);
}

sub _build_usb_bus
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_usb) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use USB');
    return undef;
  }
  my $ret_val;
  $self->RETURN_INT(sp_get_port_usb_bus_address($self->get_handle, \$ret_val, \$_));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_address
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_usb) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use USB');
    return undef;
  }
  my $ret_val;
  $self->RETURN_INT(sp_get_port_usb_bus_address($self->get_handle, \$_, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_vid
{
  my $self = shift;
  my $ret_val;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_usb) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use USB');
    return undef;
  }
  $self->RETURN_INT(sp_get_port_usb_vid_pid($self->get_handle, \$ret_val, \$_));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_pid
{
  my $self = shift;
  my $ret_val;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_usb) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use USB');
    return undef;
  }
  $self->RETURN_INT(sp_get_port_usb_vid_pid($self->get_handle, \$_, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
}

sub _build_usb_manufacturer
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_usb) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use USB');
    return undef;
  }
  $self->RETURN_OK;
  my $ret_val = sp_get_port_usb_manufacturer($self->get_handle);
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result string');
    return undef;
  }
  return $ret_val;
}

sub _build_usb_product
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_usb) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use USB');
    return undef;
  }
  $self->RETURN_OK;
  my $ret_val = sp_get_port_usb_product($self->get_handle);
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result string');
    return undef;
  }
  return $ret_val;
}

sub _build_usb_serial
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_usb) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use USB');
    return undef;
  }
  $self->RETURN_OK;
  my $ret_val = sp_get_port_usb_serial($self->get_handle);
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result string');
    return undef;
  }
  return $ret_val;
}

sub _build_bluetooth_address
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  unless ($self->is_bluetooth) {
    $self->SET_ERROR(SP_ERR_SUPP, 'Port does not use Bluetooth');
    return undef;
  }
  $self->RETURN_OK;
  my $ret_val = sp_get_port_bluetooth_address($self->get_handle);
  unless ($ret_val) {
    $self->SET_FAIL('Undefined result string');
    return undef;
  }
  return $ret_val;
}

sub _build_native_handle
{
  my $self = shift;
  my $ret_val;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_OK;
  $self->RETURN_INT(sp_get_port_handle($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
}

sub _build_signals
{
  my $self = shift;
  my $ret_val;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return undef;
  }
  $self->RETURN_OK;
  $self->RETURN_INT(sp_get_signals($self->get_handle, \$ret_val));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return undef;
  }
  return $ret_val;
}

##
#
# private backend wrapper methods
#
##

sub _free_port
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  sp_free_port($self->get_handle);
}

sub _open_port
{
  my $self = shift;
  my ($mode) = pos_validated_list( \@_,
    { isa => 'sp_mode' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  $self->RETURN_INT(sp_open($self->get_handle, $mode));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _close_port
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_close($self->get_handle));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _read_config {
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_get_config($self->get_handle, $self->config->get_handle));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
};

sub _apply_config {
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_config($self->get_handle, $self->config->get_handle));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
};

sub _set_baudrate
{
  my $self = shift;
  my ($baudrate) = pos_validated_list( \@_,
    { isa => 'sp_baudrate' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_baudrate($self->get_handle, $baudrate));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_bits
{
  my $self = shift;
  my ($bits) = pos_validated_list( \@_,
    { isa => 'sp_databits' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_bits($self->get_handle, $bits));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_parity
{
  my $self = shift;
  my ($parity) = pos_validated_list( \@_,
    { isa => 'sp_parity' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_parity($self->get_handle, $parity));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_stopbits
{
  my $self = shift;
  my ($stopbits) = pos_validated_list( \@_,
    { isa => 'sp_stopbits' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_stopbits($self->get_handle, $stopbits));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_rts
{
  my $self = shift;
  my ($rts) = pos_validated_list( \@_,
    { isa => 'sp_rts' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_rts($self->get_handle, $rts));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_cts
{
  my $self = shift;
  my ($cts) = pos_validated_list( \@_,
    { isa => 'sp_cts' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_cts($self->get_handle, $cts));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_dtr
{
  my $self = shift;
  my ($dtr) = pos_validated_list( \@_,
    { isa => 'sp_dtr' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_dtr($self->get_handle, $dtr));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_dsr
{
  my $self = shift;
  my ($dsr) = pos_validated_list( \@_,
    { isa => 'sp_dsr' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_dsr($self->get_handle, $dsr));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_xon_xoff
{
  my $self = shift;
  my ($xon_xoff) = pos_validated_list( \@_,
    { isa => 'sp_xonxoff' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_xon_xoff($self->get_handle, $xon_xoff));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _set_flowcontrol
{
  my $self = shift;
  my ($flowcontrol) = pos_validated_list( \@_,
    { isa => 'sp_flowcontrol' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_set_flowcontrol($self->get_handle, $flowcontrol));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

sub _flush
{
  my $self = shift;
  my ($buffers) = pos_validated_list( \@_,
    { isa => 'sp_buffer' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined port');
    return;
  }
  unless ($self->is_open) {
    $self->SET_FAIL('Port not open');
    return;
  }
  $self->RETURN_INT(sp_flush($self->get_handle, $buffers));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
