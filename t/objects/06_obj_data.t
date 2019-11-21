use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;

use constant COUNT    => 16;
use constant TIMEOUT  => 500;

my $list;
my $port;

# get (first) port
$list = Sigrok::SerialPort::List->new;
ok $list->is_ok, 'List->new';
if ($list->is_ok and not $list->ports->is_empty) {
  $port = $list->ports->get(0);
}

if (defined $port)
{
  my $buf;
  my $num;

  # open
  $port->open(SP_MODE_READ_WRITE);
  is $port->return_code, SP_OK, 'Port->open';

  # read
  $port->flush(SP_BUF_INPUT);
  is $port->return_code, SP_OK, 'Port->flush';
  $num = $port->input_waiting;
  ok $num >= 0, 'Port->input_waiting';
  if ($num > 0) {
    $buf = chr(0x55) x COUNT;
    ($num, $buf) = $port->blocking_read(COUNT, TIMEOUT);
    ok $num >= 0, 'Port->blocking_read';
  
    $buf = chr(0xAA) x COUNT;
    ($num, $buf) = $port->blocking_read_next(COUNT, TIMEOUT);
    ok $num >= 0, 'Port->blocking_read_next';
    
    $buf = chr(0x55) x COUNT;
    ($num, $buf) = $port->nonblocking_read(COUNT);
    ok $num >= 0, 'Port->nonblocking_read';
  }

  # write
  ok $port->drain, 'Port->drain';
  $port->flush(SP_BUF_OUTPUT);
  is $port->return_code, SP_OK, 'Port->flush';
  $num = $port->output_waiting;
  is $num, 0, 'Port->output_waiting';
  if ($num == 0) {
    $buf = chr(0xAA) x COUNT;
    $num = $port->blocking_write($buf, COUNT, TIMEOUT);
    ok $num >= 0, 'Port->blocking_write';
  
    $buf = chr(0x55) x COUNT;
    $num = $port->nonblocking_write($buf, COUNT);
    ok $num >= 0, 'Port->nonblocking_write';
  }

  # cleanup
  $port->close;
  is $port->return_code, SP_OK, 'Port->close';
  undef $port;
}

done_testing;
