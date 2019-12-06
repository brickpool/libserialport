use strict;
use Test::More tests => 1;

use Sigrok::SerialPort::Port;

my $port;
eval {
  $port = Sigrok::SerialPort::Port->new(
    portname => 'COM3',
    baudrate => undef
  );
} or warn @_;

ok $port, 'Sigrok::SerialPort::Port->new';

done_testing;
