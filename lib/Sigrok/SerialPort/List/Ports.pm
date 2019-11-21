package Sigrok::SerialPort::List::Ports;

use Moose;
use Carp qw( carp );

use Sigrok::SerialPort::Backend qw(
  sp_list_ports
  sp_free_port_list
);
use Sigrok::SerialPort::Port;

extends 'Sigrok::SerialPort::Base';

##
#
# Port enumeration
#
##

has 'port_list' => (
  is        => 'ro',
  isa       => 'ArrayRef[Sigrok::SerialPort::Port]',
  required  => 1,
  init_arg  => 'undef',
  traits    => ['Array'],
  handles   => {
    count     => 'count',
    is_empty  => 'is_empty',
    elements  => 'elements',
    get       => 'get',
  },
  # private methods
  builder   => '_build_port_list',
);

##
#
# private build methods
#
##

sub _build_port_list
{
  my $self = shift;
  my @ret_val = ();
  my @list;
  $self->RETURN_INT(sp_list_ports(\@list));
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, $self->last_error_message);
    return \@ret_val;
  }
  foreach my $handle ( @list ) {
    my $port = Sigrok::SerialPort::Port->new(handle => $handle);
    unless (defined $port) {
      $self->SET_FAIL('Undefined result');
      last;
    }
    unless ($port->is_ok) {
      $self->RETURN_INT($port->return_code);
      last;
    }
    push @ret_val, $port;
  }
  sp_free_port_list(@list);
  unless ($self->is_ok) {
    $self->SET_ERROR($self->return_code, 'Port list building failed');
    return \@ret_val;
  }
  return \@ret_val;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
