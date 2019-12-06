package Sigrok::SerialPort::List::Ports;

use Moose;
use Errno qw( :POSIX );

use Sigrok::SerialPort qw(
  SP_OK

  sp_list_ports
  sp_free_port_list
);
use Sigrok::SerialPort::Error qw(
  SET_ERROR
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

sub _build_port_list {
  my $self = shift;
  my @list;
  my @ret_val = ();
  my $ret_code = sp_list_ports(\@list);
  unless ($ret_code == SP_OK) {
    SET_ERROR($ret_code);
    return \@ret_val;
  }
  SET_ERROR(SP_OK);
  foreach my $handle ( @list ) {
    my $port;
    eval { $port = Sigrok::SerialPort::Port->new(handle => $handle) };
    unless ($port) {
      # The value has not a valid port descriptor.
      SET_ERROR(EBADF); # Bad file descriptor
      last;
    }
    push @ret_val, $port;
  }
  sp_free_port_list(@list);
  return \@ret_val;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
