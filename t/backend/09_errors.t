use strict;
use Test::More tests => 6;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Backend qw( :all );

my $port;
my $message;
my $event_set;

# init / generate error situation
is sp_get_port_by_name('error_test', \$port), SP_OK, 'sp_get_port_by_name';
is sp_new_event_set(\$event_set),             SP_OK, 'sp_new_event_set';
is sp_wait($event_set, 100),                  SP_ERR_FAIL, 'sp_wait';

# error
ok sp_last_error_code() > 0, 'sp_last_error_code';
$message = sp_last_error_message();
ok defined $message && length $message > 0, 'sp_last_error_message';
sp_free_error_message($message);
ok length $message == 0, 'sp_free_error_message';

# cleanup
sp_set_debug(1);
sp_free_event_set($event_set);
sp_set_debug(0);
sp_free_port($port);

done_testing;
