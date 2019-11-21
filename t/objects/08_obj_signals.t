use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;

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
  is $port->return_code, SP_OK, 'open';

  # signal
  my $signal = $port->get_signals;
  is $port->return_code, SP_OK, 'get_signals';
  ok $signal >= 0 && $signal <= SP_SIG_CTS|SP_SIG_DSR|SP_SIG_DCD|SP_SIG_RI, 'signal';
  ok $port->start_break,        'start_break';
  ok $port->end_break,          'end_break';
  
  # close
  $port->close();
  is $port->return_code, SP_OK, 'close';
}
  
done_testing;
