package Sigrok::SerialPort::Event;

use Moose;
use MooseX::Params::Validate;
use Carp qw( croak );

use Sigrok::SerialPort::Backend qw(
  sp_new_event_set
  sp_add_port_events
  sp_wait
  sp_free_event_set
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
  predicate => '_has_handle',
  builder   => '_build_handle',
);

has 'timeout' => (
  isa       => 'unsigned_int',
  required  => 1,
  init_arg  => 'undef',
  default   => 0,
  writer    => 'wait',
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
# extends accessor methods
#
##

after 'wait' => sub {
  shift->_wait(@_);
};

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
  $self->_free_handle if $self->_has_handle;
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
  $self->RETURN_INT(sp_add_port_events($self->get_handle, $port->get_handle, $mask));
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

sub _build_handle
{
  my $self = shift;
  my $ret_val;
  $self->RETURN_INT(sp_new_event_set(\$ret_val));
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

##
#
# private backend wrapper methods
#
##

sub _free_handle
{
  my $self = shift;
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined event set');
    return;
  }
  sp_free_event_set($self->get_handle);
}

sub _wait
{
  my $self = shift;
  my ($timeout) = pos_validated_list( \@_,
    { isa => 'unsigned_int' },
  );
  unless ($self->_has_handle) {
    $self->SET_FAIL('Undefined event set');
    return;
  }
  $self->RETURN_INT(sp_wait($self->get_handle, $timeout));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
  }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
