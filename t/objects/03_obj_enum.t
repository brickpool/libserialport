use strict;
use Test::More;
use Try::Tiny;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::List;

my $portname = 'COM3';
my $list;
my $port;

$port = Sigrok::SerialPort::Port->new(portname => $portname);
ok $port->is_ok && $port->get_handle > 0, 'Port->new(portname => ...)';

try {
  $list = Sigrok::SerialPort::List->new;
  ok $list->return_code >= SP_ERR_SUPP && $list->return_code <= SP_OK, 'List->new';

  if ($list->is_ok) {
    if ($list->ports->count > 0)
    {
      my $first = $list->ports->get(0);
      ok $first->is_ok, 'List->ports->get';
      $port = Sigrok::SerialPort::Port->new(port => $first);
      ok $port->is_ok && $port->get_handle > 0, 'Port->new(port => ...)';
      undef $port;
    }
  }
} finally {
  undef $list if $list;
};

done_testing;
