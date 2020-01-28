use strict;
use Test::More tests => 14;

use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;

use constant COUNT    => 16;
use constant TIMEOUT  => 500;

my $list;
my $port;
my $buf;
my $num;

# get (first) port
ok eval{ $list = Sigrok::SerialPort::List->new }, 'List->new';
SKIP: {
  skip 'Skipping Sigrok::SerialPort::List tests', 1
    unless defined $list and not $list->ports->is_empty;

  ok $port = $list->ports->get(0), 'List->ports->get';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port data tests', 3
    unless defined $port;

  # open
  ok $port->open('SP_MODE_READ_WRITE'), 'Port->open';

  # read
  ok $port->flush('SP_BUF_INPUT'), 'Port->flush';
  $num = $port->input_waiting;
  ok $num >= 0, 'Port->input_waiting';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port read tests', 3
    unless defined $port and $num > 0;

  # read
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

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port data tests', 3
    unless defined $port;

  # write
  ok $port->drain, 'Port->drain';
  ok $port->flush('SP_BUF_OUTPUT'), 'Port->flush';
  $num = $port->output_waiting;
  is $num, 0, 'Port->output_waiting';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port write tests', 2
    unless defined $port and $num == 0;

  $buf = chr(0xAA) x COUNT;
  $num = $port->blocking_write($buf, COUNT, TIMEOUT);
  ok $num >= 0, 'Port->blocking_write';

  $buf = chr(0x55) x COUNT;
  $num = $port->nonblocking_write($buf, COUNT);
  ok $num >= 0, 'Port->nonblocking_write';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port cleanup tests', 1
    unless defined $port;

  # cleanup
  ok $port->close(), 'Port->close';
  undef $port;
}

done_testing;
