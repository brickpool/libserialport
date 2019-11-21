use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Backend qw( :all );

use constant COUNT    => 16;
use constant TIMEOUT  => 500;

my @ports;
my $port;
my $ret;

# get (first) port
$ret = sp_list_ports(\@ports);
ok $ret >= SP_ERR_SUPP && $ret <= SP_OK, 'sp_list_ports';
if ($ret == SP_OK) {
  if (scalar @ports > 0)
  {
    $ret = sp_copy_port($ports[0], \$port);
    ok $ret == SP_OK && $port > 0, 'sp_copy_port';
  }
  sp_free_port_list(@ports);
}

if (defined $port)
{
  my $buf;
  my $num;

  # open
  is sp_open($port, SP_MODE_READ_WRITE), SP_OK, 'sp_open';

  # read
  is sp_flush($port, SP_BUF_INPUT), SP_OK, 'sp_flush';
  $num = sp_input_waiting($port);
  ok $num >= 0, 'sp_input_waiting';
  if ($num > 0) {
    $buf = chr(0x55) x COUNT;
    $num = sp_blocking_read($port, \$buf, COUNT, TIMEOUT);
    ok $num >= 0, 'sp_blocking_read';
  
    $buf = chr(0xAA) x COUNT;
    $num = sp_blocking_read_next($port, \$buf, COUNT, TIMEOUT);
    ok $num >= 0, 'sp_blocking_read_next';
  
    $buf = chr(0x55) x COUNT;
    $num = sp_nonblocking_read($port, \$buf, COUNT);
    ok $num >= 0, 'sp_nonblocking_read';
  }

  # write
  is sp_drain($port), SP_OK, 'sp_drain';
  is sp_flush($port, SP_BUF_OUTPUT), SP_OK, 'sp_flush';
  $num = sp_output_waiting($port);
  is $num, 0, 'sp_output_waiting';
  if ($num == 0) {
    $buf = chr(0xAA) x COUNT;
    $num = sp_blocking_write($port, $buf, COUNT, TIMEOUT);
    ok $num >= 0, 'sp_blocking_write';
  
    $buf = chr(0x55) x COUNT;
    $num = sp_nonblocking_write($port, $buf, COUNT);
    ok $num >= 0, 'sp_nonblocking_write';
  }

  # cleanup
  is sp_close($port), SP_OK, 'sp_close';
  sp_free_port($port);
}

done_testing;
