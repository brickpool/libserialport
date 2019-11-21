use strict;
use Test::More;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::Port::Config;

my $list;
my $port;
my $config;

# basic tests
$config = Sigrok::SerialPort::Port::Config->new;
is $config->return_code, SP_OK, 'Config->new';
undef $config;

# get (first) port
$list = Sigrok::SerialPort::List->new;
ok $list->is_ok, 'List->new';
if ($list->is_ok and not $list->ports->is_empty) {
  $port = $list->ports->get(0);
}

if (defined $port)
{
  # init
  $config = $port->config;
  is $config->return_code,  SP_OK, 'Port->config';
  $port->config($config);
  is $port->return_code,    SP_OK, 'Port->config(...)';
  $port->open(SP_MODE_READ);
  is $port->return_code,    SP_OK, 'Port->open';

  # get and set config
  my $opt;
  ok join(',', $port->configure()) =~ /baudrate/, 'Port->configure()';
  $port->configure(-baudrate => 9600);
  is $port->return_code,    SP_OK, 'Port->configure(-option)';
  $opt = $port->cget('-baudrate');
  ok $opt == 9600 && $port->is_ok, 'Port->cget(-option)';
  
  # baudrate
  my $baud;
  $config->set_baudrate(-1);
  is $config->return_code,     SP_OK, 'Config->set_baudrate';
  $config->set_baudrate(9600);
  is $config->return_code,     SP_OK, 'Config->set_baudrate';
  $baud = $config->get_baudrate;
  ok $baud == 9600 && $config->is_ok, 'Config->get_baudrate';
  $port->set_baudrate($baud);
  is $port->return_code,       SP_OK, 'Port->set_baudrate';

  # data bits
  my $bits;
  $config->set_bits(-1);
  is $config->return_code,  SP_OK, 'Config->set_bits';
  $config->set_bits(8);
  is $config->return_code,  SP_OK, 'Config->set_bits';
  $bits = $config->get_bits;
  ok $bits == 8 && $config->is_ok, 'Config->get_bits';
  $port->set_bits($bits);
  is $port->return_code,    SP_OK, 'Port->set_bits';
  
  # parity
  my $parity;
  $config->set_parity(-1);
  is $config->return_code,                 SP_OK, 'Config->set_parity';
  $config->set_parity(SP_PARITY_EVEN);
  is $config->return_code,                 SP_OK, 'Config->set_parity';
  $parity = $config->get_parity;
  ok $parity == SP_PARITY_EVEN && $config->is_ok, 'Config->get_parity';
  $port->set_parity($parity);
  is $port->return_code,                   SP_OK, 'Port->set_parity';
  
  ## stop bits
  my $stopbits;
  $config->set_stopbits(-1);
  is $config->return_code,      SP_OK, 'Config->set_stopbits';
  $config->set_stopbits(1);
  is $config->return_code,      SP_OK, 'Config->set_stopbits';
  $stopbits = $config->get_stopbits;
  ok $stopbits == 1 && $config->is_ok, 'Config->get_stopbits';
  $port->set_stopbits($stopbits);
  is $port->return_code,        SP_OK, 'Port->set_stopbits';

  # rts
  my $rts;
  $config->set_rts(-1);
  is $config->return_code,         SP_OK, 'Config->set_rts';
  $config->set_rts(SP_RTS_ON);
  is $config->return_code,         SP_OK, 'Config->set_rts';
  $rts = $config->get_rts;
  ok $rts == SP_RTS_ON && $config->is_ok, 'Config->get_rts';
  $port->set_rts($rts);
  is $port->return_code,           SP_OK, 'Port->set_rts';

  # cts
  my $cts;
  $config->set_cts(-1);
  is $config->return_code,             SP_OK, 'Config->set_cts';
  $config->set_cts(SP_CTS_IGNORE);
  is $config->return_code,             SP_OK, 'Config->set_cts';
  $cts = $config->get_cts;
  ok $cts == SP_CTS_IGNORE && $config->is_ok, 'Config->get_cts';
  $port->set_cts($cts);
  is $port->return_code,               SP_OK, 'Port->set_cts';

  # dtr
  my $dtr;
  $config->set_dtr(-1);
  is $config->return_code,         SP_OK, 'Config->set_dtr';
  $config->set_dtr(SP_DTR_ON);
  is $config->return_code,         SP_OK, 'Config->set_dtr';
  $dtr = $config->get_dtr;
  ok $dtr == SP_DTR_ON && $config->is_ok, 'Config->get_dtr';
  $port->set_dtr($dtr);
  is $port->return_code,           SP_OK, 'Port->set_dtr';

  # dsr
  my $dsr;
  $config->set_dsr(-1);
  is $config->return_code,             SP_OK, 'Config->set_dsr';
  $config->set_dsr(SP_DSR_IGNORE);
  is $config->return_code,             SP_OK, 'Config->set_dsr';
  $dsr = $config->get_dsr;
  ok $dsr == SP_DSR_IGNORE && $config->is_ok, 'Config->get_dsr';
  $port->set_dsr($dsr);
  is $port->return_code,               SP_OK, 'Port->set_dsr';

  ## xon/xoff
  my $xonxoff;
  $config->set_xon_xoff(-1);
  is $config->return_code,                 SP_OK, 'Config->set_xon_xoff';
  $config->set_xon_xoff(SP_CTS_IGNORE);
  is $config->return_code,                 SP_OK, 'Config->set_xon_xoff';
  $xonxoff = $config->get_xon_xoff;
  ok $xonxoff == SP_CTS_IGNORE && $config->is_ok, 'Config->get_xon_xoff';
  $port->set_xon_xoff($xonxoff);
  is $port->return_code,                   SP_OK, 'Port->set_xon_xoff';

  # flowcontrol
  $config->set_flowcontrol(SP_FLOWCONTROL_NONE);
  is $config->return_code, SP_OK, 'Config->set_flowcontrol';
  $port->set_flowcontrol(SP_FLOWCONTROL_NONE);
  is $port->return_code,   SP_OK, 'Port->set_flowcontrol';

  # close
  $port->close();
  is $port->return_code, SP_OK, 'Port->close';
}

done_testing;
