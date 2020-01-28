use strict;
use Test::More tests => 7;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::Event;

my $list;
my $port;
my $event;

# get (first) port
ok eval{ $list = Sigrok::SerialPort::List->new }, 'List->new';
SKIP: {
  skip 'Skipping Sigrok::SerialPort::List tests', 1
    unless defined $list and not $list->ports->is_empty;

  ok $port = $list->ports->get(0), 'List->ports->get';
}
 
SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port tests', 2
    unless defined $port;

  # open
  is $port->open('SP_MODE_READ'), SP_MODE_READ, 'Port->open';
  ok eval { $event = Sigrok::SerialPort::Event->new(port => $port, mask => 'SP_EVENT_TX_READY') }, 'Event->new';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Event tests', 2
    unless defined $event;

  # waiting
  is $event->add_port_events($port, 'SP_EVENT_RX_READY'), SP_EVENT_RX_READY, 'Event->add_port';
  is $event->wait(500), 500, 'Event->set_timeout';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port tests', 1
    unless defined $port;

  # close
  ok $port->close(), 'Port->close';
}
  
done_testing;
