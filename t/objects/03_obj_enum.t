use strict;
use Test::More tests => 6;

use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::List;

my $portname = 'COM3';
my $list;
my $port;

ok eval{ $port = Sigrok::SerialPort::Port->new(portname => $portname) }, 'Port->new(portname => ...)';
SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port tests', 1
    unless defined $port;

  ok $port->get_handle > 0, 'Port->get_handle';
  undef $port;
}

$list = Sigrok::SerialPort::List->new;
ok eval{ $list = Sigrok::SerialPort::List->new }, 'List->new';
SKIP: {
  skip 'Skipping Sigrok::SerialPort::List tests', 3
    unless defined $list and not $list->ports->is_empty;

  my $first;
  ok 1, 'not List->ports->is_empty';
  ok $first = $list->ports->get(0), 'List->ports->get';
  ok eval { $port = Sigrok::SerialPort::Port->new(port => $first) }, 'Port->new(port => ...)';
  undef $port;
}

done_testing;
