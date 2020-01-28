use strict;
use Test::More tests => 7;

use Sigrok::SerialPort qw( :const );
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
  skip 'Skipping Sigrok::SerialPort::Port tests', 5
    unless defined $port;

  # open
  ok $port->open('SP_MODE_READ'), 'open';

  # signal
  my $signal = $port->get_signals;
  ok $signal >= 0 && $signal <= (SP_SIG_CTS|SP_SIG_DSR|SP_SIG_DCD|SP_SIG_RI), 'get_signals';
  ok $port->start_break,  'start_break';
  ok $port->end_break,    'end_break';
  
  # close
  ok $port->close(), 'close';
}
  
done_testing;
