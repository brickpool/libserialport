use strict;
use warnings;

use blib;
use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::List;

my $list;
my $port;

eval{ $list = Sigrok::SerialPort::List->new };
print 'Return - new list: ', $! ? $! : 'ok', "\n";

if ($list and not $list->ports->is_empty) {
  my $first = $list->ports->get(0);
  eval{ $port = Sigrok::SerialPort::Port->new(port => $first, mode => SP_MODE_READ) };
  print 'Return - new port: ', $! ? $! : 'ok', "\n";
}
else {
  undef $list;
  print "No serial port detected\n";
}
