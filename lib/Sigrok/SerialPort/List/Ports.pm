package Sigrok::SerialPort::List::Ports;

use Moose;

use Sigrok::SerialPort qw(
  SP_OK
  SP_ERR_FAIL

  sp_list_ports
  sp_free_port_list

  sp_last_error_message
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
  foreach my $handle ( @list ) {
    my $port = Sigrok::SerialPort::Port->new(handle => $handle);
    unless ($port) {
      SET_ERROR(&Errno::EFAULT, 'Bad address');
      last;
    }
    push @ret_val, $port;
  }
  sp_free_port_list(@list);
  SET_ERROR(SP_OK);
  return \@ret_val;
}

no Moose;
__PACKAGE__->meta->make_immutable;

BEGIN {
  exists &Errno::EFAULT or
    die __PACKAGE__.' is not supported on this platform';
}

1;
