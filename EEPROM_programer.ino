/*
 * EEPROM PROGRAMMER
 * Elekes Károly 2021
 */

#include <TM1637Display.h>     // for TM1637 display
#define CLK A3                 // Clock for TM Display
#define DIO A2                 // Data  for TM Display
TM1637Display display(CLK, DIO);


#define  WE 15                 // Connect to EEPROM write enable, active low
#define  OE A0                 // Connect to EEPROM output enable, active low 
#define  CE A1                 // Connect to EEPROM chip enable, active low  

#define  A_DATA 16             // First shift register data  (SN74HC959N pin 14)
#define  A_CLK 14              // First and second shift register clock  (SN74HC959N pin 11 - SRCLK)
#define  A_LATCH 10            // First and second shift register latch clock  (SN74HC959N pin 12 -RCLK)

#define d0 2                   // EEPROM data pins to Arduino data pins: eeprom D0 ro arduino digital pin 2
#define d1 3
#define d2 4
#define d3 5
#define d4 6
#define d5 7
#define d6 8
#define d7 9

boolean init_state=false;      // variable for detecting if the programmer is connected
boolean readmode=false;        // variable for storing read or write mode
String s=" ";
String t=" ";
unsigned int adress;
int byte_count;

// Set the adress output display when programmer not connected:

    const uint8_t S1[] = { SEG_G, SEG_G,SEG_G,SEG_G};
    const uint8_t S2[] = {SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F,   // O
                          SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F,   // O
                          SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F,   // O
                          SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F,   // O
                          };


// --------   SETUP  --------  //

void setup() {
  pinMode(CLK, OUTPUT);
  pinMode(DIO, OUTPUT);
  
  analogWrite (WE,HIGH);      pinMode(WE, OUTPUT);
  digitalWrite(CE,HIGH);      pinMode(CE, OUTPUT);
  digitalWrite(OE,HIGH);      pinMode(OE, OUTPUT);
  //EEPROM is disabled at this point
  
  digitalWrite(A_DATA,LOW);   pinMode(A_DATA, OUTPUT); //adress data 
  digitalWrite(A_CLK,LOW);    pinMode(A_CLK, OUTPUT);  //adress clock
  digitalWrite(A_LATCH,LOW);  pinMode(A_LATCH, OUTPUT);//adress latch

      for (byte i=0;i<16;i++) {
                                digitalWrite(A_CLK,HIGH);
                                digitalWrite(A_CLK,LOW);}     // clear shift registers
                               
      digitalWrite(A_LATCH,HIGH);digitalWrite(A_LATCH,LOW);   //clear latch

  //Starting serial connection
  Serial.begin(500000);
  Serial.setTimeout(1);
  set_Adress(0x0000);
  display.setBrightness(0x0f);
  delay(100);  
  
 }



// --------   LOOP  --------  //
 
void loop() {
  
  s="";
  t="";


  
if (init_state==false) {  // idle when the programmer is not connected
                          delay(50);
                          byte_count++;
                          if (byte_count==8)  display.setSegments(S1); 
                          if (byte_count==1)  display.setSegments(S2); 
                          if (byte_count>16) byte_count=0;
                        }

                        

if (Serial.available ( ) > 0) 
         {   // Checking  for messages
                  char msg = Serial.read();    // Reading the data received and saving in the state variable
                  if(msg == 'i') programmer_begin();
          }  //END Checking  for messages

          
                               
if (init_state==true) {
                        
  byte_count=0;
  String code = Serial.readString(); //Read opcode from serial port
  delay(1);

if (code[0]=='i') Serial.println("EEPROM programmer already conected.");
if (code[0]=='x') programmer_end();
if (code[0]=='d') {digitalWrite(OE,HIGH);Serial.println("Output disabled.");}
if (code[0]=='e') {digitalWrite(OE,LOW);;Serial.println("Output enabled. ");}
if (code[0]=='a') {

//MULTIPLE WRITE --  a0000:[00 01 02 03 04 05 06 07 FF]
  write_mode();
  adress  =decode_adress(code);
  display.showNumberHexEx(adress); 
  int l =code.indexOf('[');
  int le =code.indexOf(']');
  String s=code.substring(l+1,le);
 
  for (int i=0;i<s.length();i=i+3) 
      {
      unsigned int databyte=decode_data(":"+s.substring(i,i+2));
      e_Write(adress,databyte);
      adress=adress+1;
      }
  delay(1);
  Serial.print("ok [");
  Serial.print(adress,HEX);
  Serial.print("]:[");
  Serial.print(adress,HEX);
  Serial.println("]");
  }
  
//SINGLE WRITE  -- w0000:FF

if (code[0]=='w') {
  write_mode();
  adress  =decode_adress(code);
  unsigned int databyte=decode_data(code);
  e_Write(adress,databyte);
  delay(1);
  display.showNumberHexEx(adress);
  read_mode();
  delay(10);
  int data1=(e_Read(adress));
  s=">"+String(adress,HEX)+":";
  t=String(data1,HEX);
  if (t.length()<2) t="0"+t;
  s=s+"["+t+"]";
  s.toUpperCase();
  Serial.println(s);
  }

// SINGLE READ
if (code[0]=='r') {
   read_mode();
   adress  =decode_adress(code);
   display.showNumberHexEx(adress);
   byte data1=(e_Read(adress));
   s=">"+String(adress,HEX)+":";
   t=String(data1,HEX);
   if (t.length()<2) t="0"+t;
   s=s+"["+t+"]";
   s.toUpperCase();
   Serial.println(s);
   }


// MULTIPLE READ
if (code[0]=='m') {
   read_mode();
   adress =decode_adress(code);
   display.showNumberHexEx(adress+0x3f); 
   s =">"+String(adress,HEX)+":[";
   for (int i=0;i<64;i++) {
                            byte data1=(e_Read(adress+i));
                            t=String(data1,HEX);
                            if (t.length()<2) t="0"+t;
                            s=s+t;
                            s=s+" ";
                           }
    s=s+"]";
    s.toUpperCase();
    Serial.println(s); 
    delay(1);
    } //END MULTIPLE READ
  } //END INIT_STATE CHECK
} //END LOOP


unsigned int decode_adress(String code) 
  {
  String a="";
  char n[4];
  char *pEnd;
  int l=code.indexOf(":");
  a=code.substring(1,l); 
  for (int i=0;i<4;i++) {n[i]=NULL; if (a[i]!=NULL) n[i]=a[i];}
  unsigned int adress=strtol (n,&pEnd,16);
  return adress;
   }

unsigned int decode_data(String code) 
  {
  String b="";
  char n[2];
  char *pEnd;
  int l=code.indexOf(":");
  b=code.substring(l+1,l+3); 
  for (int i=0;i<2;i++) {n[i]=NULL; if (b[i]!=NULL) n[i]=b[i];}
  unsigned int databyte=strtol (n,&pEnd,16);
  return databyte;
  }

void set_Adress(int adress) {
  shiftOut(A_DATA, A_CLK, MSBFIRST, adress>>8);
  shiftOut(A_DATA, A_CLK, MSBFIRST, adress);
  digitalWrite(A_LATCH,LOW);
  digitalWrite(A_LATCH,HIGH);
  digitalWrite(A_LATCH,LOW);
  delayMicroseconds(15);
  }
  
void set_Data(byte b) {
   for (int i=0;i<8;i++){
   digitalWrite(i+2,bitRead(b,i));
   delayMicroseconds(15);}
   }

//Read from EEPROM
   byte e_Read(int adress){
      set_Adress(adress);
      delayMicroseconds(1);
      boolean bit0=digitalRead(2);
      boolean bit1=digitalRead(3);
      boolean bit2=digitalRead(4);
      boolean bit3=digitalRead(5);
      boolean bit4=digitalRead(6);
      boolean bit5=digitalRead(7);
      boolean bit6=digitalRead(8);
      boolean bit7=digitalRead(9);
      byte value = bit7 << 7 | bit6 << 6 | bit5 << 5 | bit4 << 4 | bit3 << 3 | bit2 << 2 | bit1 << 1 | bit0;
      return value;
    }

//Write to EEPROM
  void e_Write(int adress, byte b){
    set_Adress(adress);      //output the adress
    set_Data(b);
    delay(10);               //wait for data  
    digitalWrite(WE,LOW);    //Write enabled
    delayMicroseconds(5);    //wait  
    digitalWrite(WE,HIGH);   //Write disabled
    }

//Enable WRITE MODE
  void write_mode() {
    digitalWrite(OE,HIGH); //turn off output for eeprom
    digitalWrite(WE,HIGH); //turn off write enable
    for (int i=d0;i<d7+1;i++){
    digitalWrite(i,LOW);
    pinMode(i,OUTPUT);}     //set arduino data pins to output
    readmode=false;
    }

//Enable READ MODE
  void read_mode() {
    if (readmode==false){
      for (int i=d0;i<d7+1;i++){pinMode(i,INPUT_PULLUP);}     //set arduino pins to input
      digitalWrite(OE,LOW); 
      digitalWrite(CE,LOW);
      digitalWrite(WE,HIGH); 
      readmode=true;}
          }

void programmer_begin() {
    init_state=true;
    digitalWrite(OE,LOW);
    digitalWrite(CE,LOW);
    set_Adress(0x0000);
    read_mode();
    Serial.println("EEPROM programmer conected.");
    }          

void programmer_end() {
    init_state=false;
    byte_count=0;
    digitalWrite(OE,HIGH);
    digitalWrite(CE,HIGH);
    Serial.println("EXIT");
     }
                   
    
