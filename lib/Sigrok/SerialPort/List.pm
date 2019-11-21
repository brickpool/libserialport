package Sigrok::SerialPort::List;

use Moose;

use Sigrok::SerialPort::List::Ports;

extends 'Sigrok::SerialPort::Base';

has 'ports' => (
  is        => 'ro',
  isa       => 'Sigrok::SerialPort::List::Ports',
  required  => 1,
  init_arg  => 'undef',
  default   => sub { Sigrok::SerialPort::List::Ports->new },
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
