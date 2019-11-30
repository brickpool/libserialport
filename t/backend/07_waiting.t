use strict;
use Test::More;

use Sigrok::SerialPort qw( :all );

my @ports;
my $port;
my $ret;

# get (first) port
$ret = sp_list_ports(\@ports);
ok $ret >= SP_ERR_SUPP && $ret <= SP_OK, 'sp_list_ports';
if ($ret == SP_OK) {
  if (scalar @ports > 0)
  {
    $ret = sp_copy_port($ports[0], \$port);
    ok $ret == SP_OK && $port > 0, 'sp_copy_port';
  }
  sp_free_port_list(@ports);
}

if (defined $port)
{
  # open
  is sp_open($port, SP_MODE_READ), SP_OK, 'sp_open';

  # waiting
  my $event_set;
  is sp_new_event_set(\$event_set),                             SP_OK, 'sp_new_event_set';
  is sp_add_port_events($event_set, $port, SP_EVENT_RX_READY),  SP_OK, 'sp_add_port_events';
  is sp_wait($event_set, 500),                                  SP_OK, 'sp_wait';
  sp_free_event_set($event_set);
  is $event_set, undef, 'sp_free_event_set';

  # cleanup
  is sp_close($port), SP_OK, 'sp_close';
  sp_free_port($port);
}
  
done_testing;
