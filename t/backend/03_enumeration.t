use strict;
use Test::More;

use Sigrok::SerialPort qw( :all );

my $portname = 'COM3';
my @ports;
my $port;
my $ret;

is sp_get_port_by_name($portname, \$port), SP_OK, 'sp_get_port_by_name';
sp_free_port($port);
is $port, undef, 'sp_free_port';

$ret = sp_list_ports(\@ports);
ok $ret >= SP_ERR_SUPP && $ret <= SP_OK, 'sp_list_ports';
if ($ret == SP_OK) {
  if (scalar @ports > 0)
  {
    $ret = sp_copy_port($ports[0], \$port);
    ok $ret == SP_OK && $port > 0, 'sp_copy_port';
    sp_free_port($port);
    is $port, undef, 'sp_free_port';
  }
  sp_free_port_list(@ports);
  ok !grep($_, @ports), 'sp_free_port_list';
}

done_testing;
