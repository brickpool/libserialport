package Sigrok::SerialPort::Event;

use Moose;
use MooseX::Params::Validate;
use Carp qw( croak );

use Sigrok::SerialPort qw(
  SP_OK

  sp_new_event_set
  sp_add_port_events
  sp_wait
  sp_free_event_set

  sp_last_error_message
);
use Sigrok::SerialPort::Error qw(
  SET_ERROR
);

extends 'Sigrok::SerialPort::Base';

##
#
# Waiting
#
##

has 'event_set' => (
  isa       => 'sp_event_set',
  required  => 1,
  lazy      => 1,
  init_arg  => 'handle',
  reader    => 'get_handle',
  # private methods
  builder   => '_build_handle',
);

has 'timeout' => (
  isa       => 'Maybe[unsigned_int]',
  required  => 1,
  init_arg  => 'undef',
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
  isa       => 'Sigrok::SerialPort::Port',
  init_arg  => 'port',
  # private methods
  clearer   => '_clear_port',
  predicate => '_has_port',
  reader    => '_get_port',
);

has '_mask' => (
  isa       => 'sp_event',
  init_arg  => 'mask',
  # private methods
  clearer   => '_clear_mask',
  predicate => '_has_mask',
  reader    => '_get_mask',
);


##
#
# extends default methods
#
##

sub BUILD {
  my $self = shift;
  if ($self->_has_port && $self->_has_mask) {
    $self->add_port_events($self->_get_port, $self->_get_mask);
  } elsif ($self->_has_port && not $self->_has_mask) {
    $self->_clear_port;
    croak 'Attribute (mask) is required if using (port)'
  } elsif ($self->_has_mask && not $self->_has_port) {
    $self->_clear_mask;
    croak 'Attribute (port) is required if using (mask)'
  }
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

sub add_port_events
{
  my $self = shift;
  my ($port, $mask) = pos_validated_list( \@_,
    { isa => 'Sigrok::SerialPort::Port' },
    { isa => 'sp_event' },
  );
  my $ret_code = sp_add_port_events($self->get_handle, $port->get_handle, $mask);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return undef;
  }
  SET_ERROR(SP_OK);
  return 1;
}

##
#
# private build methods
#
##

sub _build_handle
{
  my $self = shift;
  my $ret_val;
  my $ret_code = sp_new_event_set(\$ret_val);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return 0;
  }
  unless ($ret_val > 0) {
    SET_ERROR(&Errno::EFAULT, 'Bad address');
    return 0;
  }
  return $ret_val;
}

##
#
# private trigger methods
#
##

sub _trigger_wait
{
  my $self = shift;
  my ($new, $old) = pos_validated_list( \@_,
    { isa => 'unsigned_int' },
    { isa => 'unsigned_int', optional => 1 },
  );
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
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

sub _free_handle
{
  my $self = shift;
  unless ($self->get_handle) {
    SET_ERROR(&Errno::EBADF, 'Bad file descriptor');
    return undef;
  }
  sp_free_event_set($self->get_handle);
  SET_ERROR(SP_OK);
  return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
