# Arduino EEPROM PROGRAMMER
Arduino based eeprom programmer. Arduino firmware + PC software.
 - Load files from hard drive
 - Save files to hard drive
 - USB serial connection
 - Read from EEPROM, ROM
 - Write to EEPROM
 - can copy one ROM to an other EEPROM
 - Erase EEPROM


Hardware based on Ben Eater's https://www.youtube.com/watch?v=K88pgWhEb1Mdesign
You need 2 shift registers for the output of the adress lines. 
Connect shift register outputs to EEPROM adress lines. (First shift register, first data out pin to adress 0, second to a1 ...)
Data lines conected to arduino data pins. EEPROM data 0 to arduino digital output 2, data 1 to D3 etc.
For the adress display, use a TM1637 connected to pins A3,A2 on the arduino.

![Image 1](https://github.com/elekeskaroly/Arduino-EEPROM-PROGRAMMER/blob/main/screen%20003.jpg)
![Image 2](https://github.com/elekeskaroly/Arduino-EEPROM-PROGRAMMER/blob/main/screen%20002.jpg)
![Image 3](https://github.com/elekeskaroly/Arduino-EEPROM-PROGRAMMER/blob/main/screen%20001.jpg)

Disclaimer: I'm not a programmer, code is not optimized in any way. It's slow but it works form me.
