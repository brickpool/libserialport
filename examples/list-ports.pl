##
# An example program that makes use of libserialport for serial port access.
#
# Tested on Windows.
#
# To test, connect an Arduino or other board that appears as a serial port
# to the PC via USB.  The Arduino sketch should just periodically print
# something via Serial.println.
#
# Author: Rob Bultman
# License: MIT
##
use strict;
use warnings;
use blib;
use Sigrok::SerialPort qw(:all);

# Configuration
my $portNameBase = "COM1";
my $baudRate = 9600;
my $bits = 8;
my $stopBits = 1;
my $parity = SP_PARITY_EVEN;

##
# Wait for a port to appear.  Return a pointer to the port.
# Illustrates getting a list of ports.
##
sub GetPort() {
   my @portList;
   my $retval;
   my $port = 0;
   my $i;
   my $nameMatch; 
   my $portName;

   $port = 0;

   do {
      $retval = sp_list_ports(\@portList);

      if ($retval == SP_OK) {
         $nameMatch = -1;
         for($i=0; exists $portList[$i]; $i++) {
            $portName = sp_get_port_name($portList[$i]);
            $nameMatch = index($portName, $portNameBase);
            if ($nameMatch != -1) {
               last;
            }
         }
         if ($nameMatch != -1) {
            sp_copy_port($portList[$i], \$port);
         } else {
            print("Waiting for a serial port to appear.\n");
            sleep(1);
         }
      }

      sp_free_port_list(@portList) if @portList;
   } while ($port == 0);

   return $port;
}

##
# Configure the serial port.
##
sub ConfigureSerialPort($) {
   my ($port) = @_;
   my $retval = 0;

   if ($^O ne 'MSWin32') {
      if (SP_OK != sp_set_baudrate($port, $baudRate))
      {
         print("Unable to set port baudrate.\n");
         $retval = -1;
      } elsif(SP_OK != sp_set_bits($port, $bits)) {
         print("Unable to set port width.\n");
         $retval = -1;
      } elsif (SP_OK !=  sp_set_parity($port, $parity)) {
         print("Unable to set port parity.\n");
         $retval = -1;
      } elsif (SP_OK != sp_set_stopbits($port, $stopBits)) {
         print("Unable to set port stop bits.\n");
         $retval = -1;
      } else {
         print("Port configured.\n");
      }
   }
   else {
      # workaround for windows bug 'DCB.fParity always FALSE after a GetCommState'
      my $config;
      if (sp_new_config(\$config) != SP_OK) {
         print("Unable to create new config.\n");
         $retval = -1;
      } elsif (sp_get_config($port, $config) != SP_OK) {
         print("Unable to get config.\n");
         $retval = -1;
      } elsif (sp_set_config_baudrate($config, $baudRate) != SP_OK) {
         print("Unable to set config baudrate.\n");
         $retval = -1;
      } elsif (sp_set_config_bits($config, $bits) != SP_OK) {
         print("Unable to set config width.\n");
         $retval = -1;
      } elsif (sp_set_config_parity($config, $parity) != SP_OK) {
         print("Unable to set port parity.\n");
         $retval = -1;
      } elsif (sp_set_config_stopbits($config, $stopBits) != SP_OK) {
         print("Unable to set port stop bits.\n");
         $retval = -1;
      } elsif (sp_set_config($port, $config) != SP_OK) {
         print("Unable to set config.\n");
         $retval = -1;
      } else {
         sp_free_config($config);
         print("Port configured.\n");
      }
   }
   
   return $retval;
}

## 
# Wait for an event on the serial port.
# Illustrates use of sp_wait.
##
sub WaitForEventOnPort($) {
   my ($port) = @_;
   my $retval;
   my $eventSet = 0;

   $retval = sp_new_event_set(\$eventSet);
   if ($retval == SP_OK) {
      $retval = sp_add_port_events($eventSet, $port, SP_EVENT_RX_READY | SP_EVENT_ERROR);
      if ($retval == SP_OK) {
         $retval = sp_wait($eventSet, 10000);
      } else {
         print("Unable to add events to port.\n");
         $retval = -1;
      }
   } else {
      print("Unable to create new event set.\n");
      $retval = -1;
   }
   sp_free_event_set($eventSet);

   return $retval;
}

##
# Read data from the port.
##
sub ReadFromPort($) {
   my ($port) = @_;
   my $count = 0;
   my $bytesWaiting;
   my $buf = ' 'x256;
   my $retval;
   my $i;

   sp_flush($port, SP_BUF_INPUT);

   while ($count < 4) {
      WaitForEventOnPort($port);
      $bytesWaiting = sp_input_waiting($port);
      if ($bytesWaiting > 0) {
         $buf = '\0' x length($buf);
         $retval = sp_blocking_read($port, \$buf, length($buf)-1, 10);
         if ($retval < 0) {
            printf("Error reading from serial port: %d\n", $retval);
            $retval = -1;
            last;
         } else {
            for($i=0; $i<$retval; $i++) {
               printf("%c", unpack('x'.$i.'c1', $buf));
               if (unpack('x'.$i.'c1', $buf) == 13) {
                  $count++;
               }
            }
         }
      } elsif ($bytesWaiting < 0) {
         printf("Error getting bytes available from serial port: %d\n", $bytesWaiting);
         $retval = -1;
         last;
      }
      $retval = 0;
   }
   return $retval;
}

sub main() {
   my $retval;
   my $error = 0;
   my $port;

   do {
      $port = GetPort();

      if ($port == 0) {
         print("Did not find a suitable port.\n");
      } else {
         printf("Using %s\n", sp_get_port_name($port));
         $retval = sp_open($port, SP_MODE_READ | SP_MODE_WRITE);
         if ($retval == SP_OK) {
            print("Serial port successfully opened.\n");

            if (ConfigureSerialPort($port) == 0) {
               $error = ReadFromPort($port);
            }

            print("Closing serial port.\n");
            $retval = sp_close($port);
            if($retval == SP_OK) {
               print("Serial port closed.\n");
            } else {
               print("Unable to close serial port.\n");
            }

         } else {
            print("Error opening serial port.\n");
         }
      }

      if ($port != 0) {
         sp_free_port($port);
      }
   } while ($error != 0);

   return 0;
}

exit main();
