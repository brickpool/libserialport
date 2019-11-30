use strict;
use Test::More;

use Sigrok::SerialPort qw( :all );

my @ports;
my $port;
my $ret;
my $handle;

$ret = sp_list_ports(\@ports);
ok $ret >= SP_ERR_SUPP && $ret <= SP_OK, 'sp_list_ports';
if ($ret == SP_OK) {
  if (scalar @ports > 0)
  {
    # copy first port for using
    $ret = sp_copy_port($ports[0], \$port);
    ok $ret == SP_OK && $port > 0, 'sp_copy_port';
  }
  sp_free_port_list(@ports);
}
 
if (defined $port)
{
  # basic tests
  ok length sp_get_port_name($port)        > 0, 'sp_get_port_name';
  ok length sp_get_port_description($port) > 0, 'sp_get_port_description';
  ok        sp_get_port_transport($port)   > 0, 'sp_get_port_transport';

  if (sp_get_port_transport($port) == SP_TRANSPORT_USB)
  {
    # test usb
    my ($a, $b);
    is sp_get_port_usb_bus_address($port, \$a, \$b), SP_OK, 'sp_get_port_usb_bus_address';
    ok defined $a && defined $b, 'sp_get_port_usb_bus_address';
    $a = $b = undef;
    is sp_get_port_usb_vid_pid($port, \$a, \$b), SP_OK, 'sp_get_port_usb_vid_pid';
    ok defined $a && defined $b, 'sp_get_port_usb_vid_pid';
    $a = $b = undef;
    
    # inventory tests
    ok length sp_get_port_usb_manufacturer($port) > 0, 'sp_get_port_usb_manufacturer';
    ok length sp_get_port_usb_product($port)      > 0, 'sp_get_port_usb_product';
    ok length sp_get_port_usb_serial($port)       > 0, 'sp_get_port_usb_serial';
  }

  if (sp_get_port_transport($port) == SP_TRANSPORT_BLUETOOTH)
  {
    # test bluetooth
    ok length sp_get_port_bluetooth_address($port) > 0, 'sp_get_port_bluetooth_address';
  }

  # open port
  is sp_open($port, SP_MODE_READ), SP_OK, 'sp_open';

  # test handle
  is sp_get_port_handle($port, \$handle), SP_OK, 'sp_get_port_handle';
  ok $handle > 0, 'sp_get_port_handle';

  # close port
  is sp_close($port), SP_OK, 'sp_close';

  # free port
  sp_free_port($port);
}

done_testing;
