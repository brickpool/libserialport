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

  # signal
  my $signal;
  is sp_get_signals($port, \$signal), SP_OK, 'sp_get_signals';
  ok $signal >= 0 && $signal <= SP_SIG_CTS|SP_SIG_DSR|SP_SIG_DCD|SP_SIG_RI, 'signal';
  is sp_start_break($port),           SP_OK, 'sp_start_break';
  is sp_end_break($port),             SP_OK, 'sp_end_break';
  
  # cleanup
  is sp_close($port), SP_OK, 'sp_close';
  sp_free_port($port);
}
  
done_testing;
