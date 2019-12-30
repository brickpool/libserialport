/**
 * An example sketch to test libserialport liberay for serial port access.
 * 
 * Tested with Windows.
 * 
 * Author: https://www.renesas.com/eu/en/products/gadget-renesas/reference/gr-peach/library-serial.html 
 * License: unknown
 **/

#include <Arduino.h>
/*
Uses a FOR loop for data and prints a number in various formats.
*/
int x = 0;    // variable

void setup() {
  Serial.begin(9600, SERIAL_8E1);       // open the serial port at 9600 bps:
}
 
void loop() {  
  // print labels 
  Serial.print("RAW");      // prints a label
  Serial.print("\t");       // prints a tab
 
  Serial.print("DEC");
  Serial.print("\t");
 
  Serial.print("HEX");
  Serial.print("\t");
 
  Serial.print("OCT");
  Serial.print("\t");
 
  Serial.print("BIN");
  Serial.println("\t");
 
  for(x=0; x< 64; x++){     // only part of the ASCII chart, change to suit
 
    // print it out in many formats:
    Serial.print(x);        // print as an ASCII-encoded decimal - same as "DEC"
    Serial.print("\t");     // prints a tab
 
    Serial.print(x, DEC);   // print as an ASCII-encoded decimal
    Serial.print("\t");     // prints a tab
 
    Serial.print(x, HEX);   // print as an ASCII-encoded hexadecimal
    Serial.print("\t");     // prints a tab
 
    Serial.print(x, OCT);   // print as an ASCII-encoded octal
    Serial.print("\t");     // prints a tab
 
    Serial.println(x, BIN); // print as an ASCII-encoded binary
                            // then adds the carriage return with "println"
    delay(200);             // delay 200 milliseconds
  }
  Serial.println("");       // prints another carriage return
}
