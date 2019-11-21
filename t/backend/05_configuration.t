use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::Backend qw( :all );

my @ports;
my $port;
my $ret;
my $config;

# basic tests
is sp_new_config(\$config), SP_OK, 'sp_new_config';
sp_free_config($config);

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
  # init
  is sp_new_config(\$config),       SP_OK, 'sp_new_config';
  is sp_open($port, SP_MODE_READ),  SP_OK, 'sp_open';

  # get and set config
  is sp_get_config($port, $config), SP_OK, 'sp_get_config';
  is sp_set_config($port, $config), SP_OK, 'sp_set_config';
  
  # baudrate
  my $baud;
  is sp_set_config_baudrate($config, -1),     SP_OK, 'sp_set_config_baudrate';
  is sp_set_config_baudrate($config, 9600),   SP_OK, 'sp_set_config_baudrate';
  is sp_get_config_baudrate($config, \$baud), SP_OK, 'sp_get_config_baudrate';
  is $baud, 9600, 'sp_get_config_baudrate';
  is sp_set_baudrate($port, $baud),           SP_OK, 'sp_set_baudrate';

  # data bits
  my $bits;
  is sp_set_config_bits($config, -1),     SP_OK, 'sp_set_config_bits';
  is sp_set_config_bits($config, 8),      SP_OK, 'sp_set_config_bits';
  is sp_get_config_bits($config, \$bits), SP_OK, 'sp_get_config_bits';
  is $bits, 8, 'sp_set_bits';
  is sp_set_bits($port, $bits),           SP_OK, 'sp_set_bits';

  # parity
  my $parity;
  is sp_set_config_parity($config, -1),             SP_OK, 'sp_set_config_parity';
  is sp_set_config_parity($config, SP_PARITY_EVEN), SP_OK, 'sp_set_config_parity';
  is sp_get_config_parity($config, \$parity),       SP_OK, 'sp_get_config_parity';
  is $parity, SP_PARITY_EVEN, 'sp_set_parity';
  is sp_set_parity($port, $parity),                 SP_OK, 'sp_set_parity';
  
  # stop bits
  my $stopbits;
  is sp_set_config_stopbits($config, -1),         SP_OK, 'sp_set_config_stopbits';
  is sp_set_config_stopbits($config, 1),          SP_OK, 'sp_set_config_stopbits';
  is sp_get_config_stopbits($config, \$stopbits), SP_OK, 'sp_get_config_stopbits';
  is $stopbits, 1, 'sp_set_stopbits';
  is sp_set_stopbits($port, $stopbits),           SP_OK, 'sp_set_stopbits';

  # rts
  my $rts;
  is sp_set_config_rts($config, -1),        SP_OK, 'sp_set_config_rts';
  is sp_set_config_rts($config, SP_RTS_ON), SP_OK, 'sp_set_config_rts';
  is sp_get_config_rts($config, \$rts),     SP_OK, 'sp_get_config_rts';
  is $rts, SP_RTS_ON, 'sp_set_rts';
  is sp_set_rts($port, $rts),               SP_OK, 'sp_set_rts';

  # cts
  my $cts;
  is sp_set_config_cts($config, -1),            SP_OK, 'sp_set_config_cts';
  is sp_set_config_cts($config, SP_CTS_IGNORE), SP_OK, 'sp_set_config_cts';
  is sp_get_config_cts($config, \$cts),         SP_OK, 'sp_get_config_cts';
  is $cts, SP_CTS_IGNORE, 'sp_set_cts';
  is sp_set_cts($port, $cts),                   SP_OK, 'sp_set_cts';

  # dtr
  my $dtr;
  is sp_set_config_dtr($config, -1),        SP_OK, 'sp_set_config_dtr';
  is sp_set_config_dtr($config, SP_DTR_ON), SP_OK, 'sp_set_config_dtr';
  is sp_get_config_dtr($config, \$dtr),     SP_OK, 'sp_get_config_dtr';
  is $dtr, SP_DTR_ON, 'sp_set_dtr';
  is sp_set_dtr($port, $dtr),               SP_OK, 'sp_set_dtr';

  # dsr
  my $dsr;
  is sp_set_config_dsr($config, -1),            SP_OK, 'sp_set_config_dsr';
  is sp_set_config_dsr($config, SP_DSR_IGNORE), SP_OK, 'sp_set_config_dsr';
  is sp_get_config_dsr($config, \$dsr),         SP_OK, 'sp_get_config_dsr';
  is $dsr, SP_DSR_IGNORE, 'sp_set_dsr';
  is sp_set_dsr($port, $dsr),                   SP_OK, 'sp_set_dsr';

  # xon/xoff
  my $xonxoff;
  is sp_set_config_xon_xoff($config, -1),                   SP_OK, 'sp_set_config_xon_xoff';
  is sp_set_config_xon_xoff($config, SP_XONXOFF_DISABLED),  SP_OK, 'sp_set_config_xon_xoff';
  is sp_get_config_xon_xoff($config, \$xonxoff),            SP_OK, 'sp_get_config_xon_xoff';
  is $xonxoff, SP_XONXOFF_DISABLED, 'sp_set_xon_xoff';
  is sp_set_xon_xoff($port, $xonxoff),                      SP_OK, 'sp_set_xon_xoff';

  # flowcontrol
  is sp_set_config_flowcontrol($config, SP_FLOWCONTROL_NONE), SP_OK, 'sp_set_config_flowcontrol';
  is sp_set_flowcontrol($port, SP_FLOWCONTROL_NONE),          SP_OK, 'sp_set_flowcontrol';

  # done
  sp_free_config($config);
  is $config, undef, 'sp_free_config';
  is sp_close($port), SP_OK, 'sp_close';
  sp_free_port($port);
}

done_testing;
