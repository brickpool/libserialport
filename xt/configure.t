use strict;
use Test::More tests => 29;

use Sigrok::SerialPort qw(SP_MODE_READ_WRITE SP_FLOWCONTROL_NONE);
use Sigrok::SerialPort::List;

my $port;
my $name;

ok eval { $port = Sigrok::SerialPort::List->new->ports->get(0) }, 'Sigrok::SerialPort::List->new';
ok $name = $port->get_name, "Port->get_name(); => $name";

SKIP: {
  skip 'Skipping Sigrok::SerialPort::Port config tests', 28
    unless defined $port;

  # undef
  is eval { $port->configure(0) } || -1, -1, 'Port->configure(0); => false argument';
  is eval { $port->cget(0)      } || -1, -1, 'Port->cget(0); => false argument';

  # open
  ok $port->open(SP_MODE_READ_WRITE), 'Port->open('.SP_MODE_READ_WRITE.');';
  ok defined $port->configure, 'Port->configure(); => defined';

  # cget/configure
  is $port->configure, 10, 'Port->configure(); => scalar';
  foreach my $option ( $port->configure ) {
    my $val;
    if ($option =~ /flowcontrol/) {
      $val = SP_FLOWCONTROL_NONE;
      ok defined $val, "flowcontrol = $val";
    } else {
      $val = $port->cget($option);
      ok defined $val, "Port->cget($option);";
    }
    ok $port->configure($option => $val), "Port->configure($option => $val);";
  }
  ok $port->write_settings, 'Port->write_settings();';

  # cleanup
  ok $port->close(), 'Port->close();';
  undef $port;
}

done_testing;
