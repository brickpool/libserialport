package Sigrok::SerialPort::Event;

# Serialport library
use Sigrok::SerialPort qw(
  SP_OK

  sp_new_event_set
  sp_add_port_events
  sp_wait
  sp_free_event_set
);
use Sigrok::SerialPort::Types qw(
  Int_sp_event
  Int_sp_event_set
);
use Sigrok::SerialPort::Error qw(
  SET_ERROR
);

# Standard packages
use Carp qw( croak );
use English qw( -no_match_vars );
use Errno qw( :POSIX );

# Use of Modern Perl
use Moo;
#use namespace::autoclean;
use Types::Standard qw( Object InstanceOf Optional );
use Types::Common::Numeric qw( PositiveOrZeroInt );
use Type::Params qw( validate );

extends 'Sigrok::SerialPort::Base';

##
#
# Waiting
#
##

has 'event_set' => (
  is        => 'ro',
  isa       => Int_sp_event_set,
  required  => 1,
  lazy      => 1,
  init_arg  => 'handle',
  reader    => 'get_handle',
  # private methods
  builder   => '_build_handle',
);

has 'timeout' => (
  is        => 'rw',
  isa       => PositiveOrZeroInt,
  required  => 1,
  init_arg  => undef,
  default   => 0,
  writer    => 'wait',
  # private methods
  trigger   => \&_trigger_wait,
);

##
#
# helper attributes
#
##

has '_port' => (
  is        => 'ro',
  isa       => InstanceOf['Sigrok::SerialPort::Port'],
  init_arg  => 'port',
  # private methods
  reader    => '_get_port',
);

has '_mask' => (
  is        => 'ro',
  isa       => Int_sp_event,
  coerce    => 1,
  init_arg  => 'mask',
  # private methods
  reader    => '_get_mask',
);

##
#
# extends accessor methods
#
##

around 'wait' => sub {
  my ($code, $self, $arg) = @_;
  my $ret_val = $self->_trigger_wait($arg);
  return defined $ret_val ? $self->$code($ret_val) : undef;
};

##
#
# extends default methods
#
##

sub BUILD {
  my $self = shift;
  if (defined $self->{_port} and defined $self->{_mask}) {
    defined $self->add_port_events($self->_get_port, $self->_get_mask)
      or croak $ERRNO;
  } elsif (exists $self->{_port}) {
    croak 'Attribute (mask) is required if using (port)'
  } elsif (exists $self->{_mask}) {
    croak 'Attribute (port) is required if using (mask)'
  }
  # we don't need the helper attributes anymore
  delete $self->{_port} if $self->_get_port;
  delete $self->{_mask} if $self->_get_mask;
}

sub DEMOLISH {
  my $self = shift;
  $self->_free_handle if $self->get_handle;
}

##
#
# additional public methods
#
##

sub add_port_events {
  my ($self, $port, $mask) = validate( \@_,
    Object,
    InstanceOf['Sigrok::SerialPort::Port'],
    Int_sp_event,
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  unless ($port->get_handle) {
    # One or more of the parameters specified by parameter list is invalid.
    SET_ERROR(EINVAL); # Invalid argument
    return undef;
  }
  my $ret_code = sp_add_port_events($self->get_handle, $port->get_handle, $mask);
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

sub _build_handle {
  my $self = shift;
  my $ret_val;
  my $ret_code = sp_new_event_set(\$ret_val);
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

sub _trigger_wait {
  my ($self, $new, $old) = validate( \@_,
    Object,
    PositiveOrZeroInt,
    Optional[PositiveOrZeroInt],
  );
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  my $ret_code = sp_wait($self->get_handle, $new);
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

sub _free_handle {
  my $self = shift;
  unless ($self->get_handle) {
    # The value of the config argument is invalid.
    SET_ERROR(ENXIO); # No such device or address
    return undef;
  }
  sp_free_event_set($self->get_handle);
  return 1;
}

no Moo;

1;
