use strict;
use Test::More tests => 65;

use Sigrok::SerialPort qw( :const );
use Sigrok::SerialPort::List;
use Sigrok::SerialPort::Port;
use Sigrok::SerialPort::Port::Config;

my $list;
my $port;
my $config;

# basic tests
ok eval{ $config = Sigrok::SerialPort::Port::Config->new }, 'Config->new';
undef $config if defined $config;

# get (first) port
ok eval{ $list = Sigrok::SerialPort::List->new }, 'List->new';
SKIP: {
  skip 'Skipping Sigrok::SerialPort::List tests', 1
    unless defined $list and not $list->ports->is_empty;

  ok $port = $list->ports->get(0), 'List->ports->get';
}

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port tests', 62
    unless defined $port;

  # init
  ok $config = $port->config,   'Port->config';
  ok $port->config($config),    'Port->config(...)';
  ok $port->open(SP_MODE_READ), 'Port->open';

  # get and set config
  my ($opt, $val);
  is scalar (@_ = $port->configure), 10,        'Port->configure()';
  ok $port->configure(-baudrate => 9600),       'Port->configure(-baudrate => ...)';
  ok $port->write_settings,                     'Port->write_settings';
  is $port->cget('-baudrate'), 9600,            'Port->cget(-baudrate)';
  foreach $opt ( qw(bits parity stopbits rts cts dtr dsr xon_xoff) ) {
    my $val = $port->cget("-$opt");
    ok defined $val, "Port->cget(-$opt)";
    ok defined $port->configure("-$opt" => $val), "Port->configure(-$opt => $val)";
  }
  
  # baudrate
  my $baud;
  is $config->set_baudrate(-1),       -1, 'Config->set_baudrate';
  is $config->set_baudrate(2400),   2400, 'Config->set_baudrate';
  is $baud = $config->get_baudrate, 2400, 'Config->get_baudrate';
  is $port->set_baudrate($baud),    2400, 'Port->set_baudrate';

  # data bits
  my $bits;
  is $config->set_bits(-1),    -1, 'Config->set_bits';
  is $config->set_bits(8),      8, 'Config->set_bits';
  is $bits = $config->get_bits, 8, 'Config->get_bits';
  is $port->set_bits($bits),    8, 'Port->set_bits';
  
  # parity
  my $parity;
  is $config->set_parity(-1),                           -1, 'Config->set_parity';
  is $config->set_parity('SP_PARITY_EVEN'), SP_PARITY_EVEN, 'Config->set_parity';
  is $parity = $config->get_parity,         SP_PARITY_EVEN, 'Config->get_parity';
  is $port->set_parity($parity),            SP_PARITY_EVEN, 'Port->set_parity';
  
  ## stop bits
  my $stopbits;
  is $config->set_stopbits(-1),        -1, 'Config->set_stopbits';
  is $config->set_stopbits(1),          1, 'Config->set_stopbits';
  is $stopbits = $config->get_stopbits, 1, 'Config->get_stopbits';
  is $port->set_stopbits($stopbits),    1, 'Port->set_stopbits';

  # rts
  my $rts;
  is $config->set_rts(-1),                 -1, 'Config->set_rts';
  is $config->set_rts('SP_RTS_ON'), SP_RTS_ON, 'Config->set_rts';
  is $rts = $config->get_rts,       SP_RTS_ON, 'Config->get_rts';
  is $port->set_rts($rts),          SP_RTS_ON, 'Port->set_rts';

  # cts
  my $cts;
  is $config->set_cts(-1),                         -1, 'Config->set_cts';
  is $config->set_cts('SP_CTS_IGNORE'), SP_CTS_IGNORE, 'Config->set_cts';
  is $cts = $config->get_cts,           SP_CTS_IGNORE, 'Config->get_cts';
  is $port->set_cts($cts),              SP_CTS_IGNORE, 'Port->set_cts';

  # dtr
  my $dtr;
  is $config->set_dtr(-1),                 -1, 'Config->set_dtr';
  is $config->set_dtr('SP_DTR_ON'), SP_DTR_ON, 'Config->set_dtr';
  is $dtr = $config->get_dtr,       SP_DTR_ON, 'Config->get_dtr';
  is $port->set_dtr($dtr),          SP_DTR_ON, 'Port->set_dtr';

  # dsr
  my $dsr;
  is $config->set_dsr(-1),                         -1, 'Config->set_dsr';
  is $config->set_dsr('SP_DSR_IGNORE'), SP_DSR_IGNORE, 'Config->set_dsr';
  is $dsr = $config->get_dsr,           SP_DSR_IGNORE, 'Config->get_dsr';
  is $port->set_dsr($dsr),              SP_DSR_IGNORE, 'Port->set_dsr';

  ## xon/xoff
  my $xonxoff;
  is $config->set_xon_xoff(-1),                                      -1, 'Config->set_xon_xoff';
  is $config->set_xon_xoff('SP_XONXOFF_DISABLED'),  SP_XONXOFF_DISABLED, 'Config->set_xon_xoff';
  is $xonxoff = $config->get_xon_xoff,              SP_XONXOFF_DISABLED, 'Config->get_xon_xoff';
  is $port->set_xon_xoff($xonxoff),                 SP_XONXOFF_DISABLED, 'Port->set_xon_xoff';

  # flowcontrol
  is $config->set_flowcontrol('SP_FLOWCONTROL_NONE'), SP_FLOWCONTROL_NONE, 'Config->set_flowcontrol';
  is $port->set_flowcontrol('SP_FLOWCONTROL_NONE'),   SP_FLOWCONTROL_NONE, 'Port->set_flowcontrol';

  # close
  ok $port->close(), 'Port->close';
}

done_testing;
