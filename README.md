# Arduino-EEPROM-PROGRAMMER
Arduino based eeprom programmer. Arduino firmware + PC software.
 - Load files from hard drive
 - Save files to hard drive
 - USB serial connection
 - Read from EEPROM, ROM
 - Write to EEPROM
 - can copy one ROM to an other EEPROM
 - Erase EEPROM


It's based mainly on Ben Eater's design. But has a few differences.  
You need 2 shift registers for the output of the adress lines. 
Connect shift register outputs to EEPROM adresses. (First shift register, first data out pin to adress 0)
Data lines conected to arduino data pins. EEPROM data 0 to arduino digital output 2.

![Image 1](https://github.com/elekeskaroly/Arduino-EEPROM-PROGRAMMER/blob/main/screen%20003.jpg)
![Image 2](https://github.com/elekeskaroly/Arduino-EEPROM-PROGRAMMER/blob/main/screen%20002.jpg)
![Image 3](https://github.com/elekeskaroly/Arduino-EEPROM-PROGRAMMER/blob/main/screen%20001.jpg)

Disclaimer: I'm not a programmer, code is not optimized in any way. It's slow but it works form me.
