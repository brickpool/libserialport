use strict;
use Test::More tests => 19;

use Sigrok::SerialPort qw( SP_MODE_READ );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;

my $list;
my $port;

# get (first) port
ok eval{ $list = Sigrok::SerialPort::List->new }, 'List->new';
SKIP: {
  skip 'Skipping Sigrok::SerialPort::List tests', 1
    unless defined $list and not $list->ports->is_empty;

  ok $port = $list->ports->get(0), 'List->ports->get';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port basic tests', 3
    unless defined $port;

  # basic tests
  ok length $port->get_name         > 0, 'get_name';
  ok length $port->get_description  > 0, 'get_description';
  ok        $port->get_transport    > 0, 'get_transport';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port usb tests', 8
    unless defined $port and $port->is_usb;
    
  # test usb
  ok defined $port->get_usb_bus,      'get_usb_bus';
  ok defined $port->get_usb_address,  'get_usb_address';
  ok defined $port->get_usb_vid,      'get_usb_vid';
  ok defined $port->get_usb_pid,      'get_usb_pid';

  # inventory tests
  ok length $port->get_usb_manufacturer > 0, 'get_usb_manufacturer';
  ok length $port->get_usb_product      > 0, 'get_usb_product';
  ok length $port->get_usb_serial       > 0, 'get_usb_serial';

  # @list
  is $port->get_usb('-bus', '-address', '-vid', '-pid', '-manufacturer', '-product', '-serial'), 7, 'get_usb';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port bluetooth tests', 1
    unless defined $port and $port->is_bluetooth;

  ok length $port->get_bluetooth_address > 0, 'get_bluetooth_address';
}
  
SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port system tests', 5
    unless defined $port;

  # open port
  ok $port->open(SP_MODE_READ), 'set_mode';
  ok $port->is_open, 'open';

  # test handle
  ok defined $port->get_handle(),       'get_handle';
  ok defined $port->get_native_handle,  'get_native_handle';

  # close port
  $port->close;
  ok !$port->is_open, 'close';
}

done_testing;
