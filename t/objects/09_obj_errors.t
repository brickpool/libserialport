use strict;
use Test::More tests => 6;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Error qw( SET_ERROR );
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::Event;

my $port;
my $message;
my $event;

# init / generate error situation
ok eval { $port = Sigrok::SerialPort::Port->new(portname => 'error_test') }, 'Port->new';
ok eval { $event = Sigrok::SerialPort::Event->new(port => $port, mask => SP_EVENT_TX_READY) }, 'Event->new';
is $event->wait(100) || SP_ERR_FAIL, SP_ERR_FAIL, 'Event->wait';

## error
is Sigrok::SerialPort::Error::last_error_code(), 6, 'Error->last_error_code';
$message = Sigrok::SerialPort::Error::last_error_message();
ok defined $message && length $message > 0, 'Error->last_error_message';

## cleanup
Sigrok::SerialPort::Error::set_debug(1);
undef $event;
Sigrok::SerialPort::Error::set_debug(0);
undef $port;

sub error_testing { ok SET_ERROR(SP_OK, "message"), 'SET_ERROR(err, msg)' }
error_testing;

done_testing;
