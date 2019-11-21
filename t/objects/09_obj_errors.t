use strict;
use Test::More tests => 5;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::Event;

my $port;
my $message;
my $event;

# init / generate error situation
$port = Sigrok::SerialPort::Port->new(portname => 'error_test');
ok $port->is_ok, 'Port->new';
$event = Sigrok::SerialPort::Event->new(port => $port, mask => SP_EVENT_TX_READY);
ok $event->is_ok, 'Event->new';
$event->wait(100);
is $event->return_code, SP_ERR_FAIL, 'Event->wait';

## error
ok $port->last_error_code() > 0, 'Port->last_error_code';
$message = $port->last_error_message();
ok defined $message && length $message > 0, 'Port->last_error_message';

## cleanup
$port->set_debug(1);
undef $event;
$port->set_debug(0);
undef $port;

done_testing;
