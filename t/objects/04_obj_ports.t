use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;

my $list;
my $port;

$list = Sigrok::SerialPort::List->new;
ok $list->is_ok, 'List->new';
if ($list->is_ok and not $list->ports->is_empty) {
  $port = $list->ports->get(0);
}

if (defined $port)
{
  # basic tests
  ok length $port->get_name         > 0, 'get_name';
  ok length $port->get_description  > 0, 'get_description';
  ok        $port->get_transport    > 0, 'get_transport';

  if ($port->is_usb) {
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
    ok defined $port->get_usb('-bus', '-address'), 'get_usb';
  }

  if ($port->is_bluetooth) {
    ok length $port->get_bluetooth_address > 0, 'get_bluetooth_address';
  }
  
  # open port
  $port->open(SP_MODE_READ);
  is $port->return_code, SP_OK, 'open';

  # test handle
  ok defined $port->get_handle(),       'get_handle';
  ok defined $port->get_native_handle,  'get_native_handle';

  # close port
  $port->close;
  is $port->return_code, SP_OK, 'close';
}

done_testing;
