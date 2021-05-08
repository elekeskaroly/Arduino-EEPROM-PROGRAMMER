
import processing.core.*;
import processing.event.*;
import controlP5.*;
import geomerative.*;
import processing.serial.*;
import java.util.Map;

long baudRate =500000;

PImage img;
PImage ico;
int error_count=0;     // variable for counting errors
int byte_count=0;      // variable for counting bytes
int epromsize=0x1F40;  //Set default EEPROM size;
int step=0;
int epromadress=0;

boolean process=false; 
boolean wait=true;
boolean file_event=false;
boolean openfile;
boolean savefile;

boolean init_state=false;
boolean connected_status=false;
boolean readeprom=false;
boolean writeeprom=false;
boolean eraseeeprom=false;
String  status_msg;
String str1;
String str2="";
String val;
String data1="";
String sfilename;
String data11;
String serialstring;

ControlP5 cp5;
Serial myPort;  //the Serial port object
PApplet applet = this;
PFont myFont;
color bcolor = color(150,150,160);
ArrayList<String> comPorts = new ArrayList<String>();
// -----  SETUP -----  //

void setup() {
  size(500,620);
  surface.setTitle("Eeprom - programmer  v0.1");
  img = loadImage("eprom.png");
  listPorts();  
  createcp5GUI();
  noStroke();
  
  textAlign(LEFT);
  myFont = createFont("Segoe UI", 12);
  status_msg="--";
  init_state=false;
 }



void draw() {
  background(bcolor);
  fill(#aa0000);
  rect(-1,598,510,26);
  noFill();
  stroke(10,10,60);  
  rect(19,149,461,401);
  fill(#fcfcfc);
  image(img, 20, 50);
  textFont(createFont("Courier New", 13));
  text("00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F",83,145);
  textFont(myFont);
  text("| size: "+str(epromsize)+" bytes", 380, 613);
  if (connected_status==true) text("| Connected |",20,613); else  text("| Not connected |",20,613);
  float a =myTextarea.getScrollPosition();
  myTextarea2.scroll(1-a);
  cp5.draw();
  text(status_msg,120,613);

// -----  SAVE FILE ---- 
if (file_event==true & savefile==true) {
    byte[] nums=new byte[epromsize];
    if (data1!="") {
                    String[] q = splitTokens(data1);
                    for (int i=0; i<epromsize;i++){
                         int j =unhex(q[i]);
                         nums[i]=byte(j); }
                     if (sfilename!=null) saveBytes(sfilename, nums);
                    }
    savefile=false;
    file_event=false;
   }

// -----  OPEN FILE ----
if (file_event==true & openfile==true){
  data1="";
  str2=hex(0).substring(4,8)+": \n";
  int j=0;
  // Open a file and read its binary data 
    byte b[] = loadBytes(sfilename); 
    for (int i = 0; i < b.length; i++) {
        data1=data1+hex(b[i])+" ";
        status_msg=str(i+1)+" bytes loaded.";
        if (j>15) {j=0; str2=str2+hex(i).substring(4,8)+": \n";}
        j++;}
  myTextarea2.setText(str2);
  myTextarea.setText(data1);
  file_event=false;
  openfile=false;
 }
 
 
// -----  ERASE EEPROM ----

if (eraseeeprom==true) {
  if (init_state==true){
      String str="a"+hex(epromadress).substring(4,8)+":[FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF ]";
      boolean next=false;
      myPort.write(str);
      delay(1);
      while (next==false) {
        serialstring = myPort.readStringUntil('\n');
        if (serialstring==null) {myPort.write(str);delay(5);}
        if (serialstring!=null) {
                                  if (serialstring.contains("ok")) {
                                              next=true;
                                              epromadress+=32;
                                              slider1.setValue(epromadress);
                                              byte_count++;}
                                 }    
                             }
                             
       if (epromadress>=epromsize) {eraseeeprom=false;
                                    clearbutton.setCaptionLabel("Erase");
                                    error_count=0;
                                    status_msg=status_msg+" OK";
                                    epromadress=0;
                                    byte_count=0;
                                    step=0;
                                    slider1.setVisible(false);}
   }} 
  


// -----  WRITE EEPROM ----

if (writeeprom==true) {
 if (init_state==true){
      data11=data1.substring(step,step+96);
      String str="a"+hex(epromadress).substring(4,8)+":["+data11+"]";
      boolean next=false;
      myPort.write(str);
      delay(1);
   
      while (next==false) {
        serialstring = myPort.readStringUntil('\n');
        if (serialstring==null) {myPort.write(str);delay(5);}        
        if (serialstring!=null) {if (serialstring.contains("ok")) {
                                    next=true;
                                    epromadress+=32;
                                    slider1.setValue(epromadress);
                                    byte_count++;
                                    step+=96;}
                                }    
                          }

    if (epromadress>=epromsize) {writeeprom=false;
                                 writebutton.setCaptionLabel("Write");
                                 error_count=0;
                                 status_msg=str(byte_count)+" bytes written: 0000 to "+hex(byte_count).substring(4,8);
                                 epromadress=0;
                                 byte_count=0;
                                 step=0;slider1.setVisible(false);}
     }  
}
  
  


   
if (readeprom==true) {
 
if (init_state==true) {
  String str="m"+hex(epromadress).substring(4,8);
  myPort.write(str);delay(2);
  process=false;
  boolean next=false;
      while (next==false) {
      serialstring = myPort.readStringUntil('\n');
      if (serialstring==null)  { myPort.write(str);delay(2);}
      if (serialstring!=null)  {//println(serialstring);//re=hex(br).substring(4,8)+":"+str(er)+" errors !";
                                //if (serialstring.contains("error")) { println("E01");serialstring=null;next=true;process=false;error_count=er+1;re=hex(br).substring(4,8)+"   Corrected: "+str(er)+" errors !";}else 
                                {next=true;
                                 epromadress+=64;
                                 process=true;}
                                }
  if (process==true) {
      int l =serialstring.indexOf('[');
      int le =serialstring.indexOf(']');
      String s=serialstring.substring(l+1,le-1);
      String[] q = splitTokens(s);
      str2=str2+hex(epromadress-64).substring(4,8)+": \n"+hex(epromadress-48).substring(4,8)+": \n"+hex(epromadress-32).substring(4,8)+": \n"+hex(epromadress-16).substring(4,8)+": \n";
      for (int i=0; i<q.length;i++){
                                    data1=data1+q[i]+" ";
                                    byte_count++;
                                   }
      myTextarea2.setText(str2);
      myTextarea.setText(data1);
      slider1.setValue(epromadress);}
    }
    
    if (epromadress>=epromsize) {readeprom=false;
                                 readbutton.setCaptionLabel("Read EEPROM");
                                 error_count=0;
                                 status_msg=str(byte_count)+" bytes read sucessfully. From: 0000 to "+hex(byte_count-1).substring(4,8);
                                 epromadress=0;byte_count=0;
                                 slider1.setVisible(false);}
  }
 else {status_msg="No connection !";readeprom=false;}
}
}
 
  
  
