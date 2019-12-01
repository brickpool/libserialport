use strict;
use Test::More tests => 6;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Error qw( SET_ERROR last_error_code last_error_message set_debug );
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::Event;

my $port;
my $event;

# init / generate error situation
ok eval { $port = Sigrok::SerialPort::Port->new(portname => 'error_test') }, 'Port->new';
ok eval { $event = Sigrok::SerialPort::Event->new(port => $port, mask => SP_EVENT_TX_READY) }, 'Event->new';
is $event->wait(100) || SP_ERR_FAIL, SP_ERR_FAIL, 'Event->wait';

## error
is last_error_code(), 6, 'last_error_code';
ok length last_error_message() > 0, 'last_error_message';

## cleanup
set_debug(1);
undef $event;
set_debug(0);
undef $port;

ok SET_ERROR(SP_OK, "ok message"), 'SET_ERROR(err, msg)';

done_testing;
