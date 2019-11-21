use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::Event;

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
  # open
  $port->open(SP_MODE_READ);
  is $port->return_code, SP_OK, 'Port->open';

  # waiting
  my $event;
  $event = Sigrok::SerialPort::Event->new(port => $port, mask => SP_EVENT_TX_READY);
  is $event->return_code, SP_OK, 'Event->new';
  $event->add_port_events($port, SP_EVENT_RX_READY);
  is $event->return_code, SP_OK, 'Event->add_port';
  $event->wait(500);
  is $event->return_code, SP_OK, 'Event->set_timeout';

  # close
  $port->close();
  is $port->return_code, SP_OK, 'Port->close';
}
  
done_testing;
