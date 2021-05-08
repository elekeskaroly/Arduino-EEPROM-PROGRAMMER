ArrayList<Byte> bytes = new ArrayList<Byte>();
String val2;
 void listPorts() {
        comPorts.add("Disconnect");
        for (int i = 0; i < Serial.list().length; i++) {
            String name = Serial.list()[i];
            int dot = name.indexOf('.');
            if (dot >= 0)
                name = name.substring(dot + 1);
            if (!name.contains("luetooth")) {
                comPorts.add(name);
                println(name);
            }
        }
    }


void disconnect() {
        myPort.write('x');
        if (myPort != null)
            myPort.stop();
        myPort = null;
        println("Disconnected");
        println("No init");
        connected_status=false;
        init_state=false;
    }

 void connect(int port) {
        
        try {
            myPort = new Serial(applet, Serial.list()[port], (int) baudRate);
            myPort.buffer(1024);
            
            
            connected_status=true;    
            println("Port open.");
            init_state=false;
            connected_status=false;         
        } catch (Exception exp) {
            exp.printStackTrace();
            println(exp);
        }
    }

 void connect(String name) {
        for (int i = 0; i < Serial.list().length; i++) {
            if (Serial.list()[i].contains(name)) {
                connect(i);
                connected_status=true;    
                return;
            }}
        disconnect();
        
        init_state=false;
        }

   
void init()
{
  
  delay(100);
  val="ni"; 
  myPort.write('i');

  print("Init:");
  delay(1000);
  while (val.equals("ni")) {
  byte_count++;
  if (byte_count>100) {val="nope";init_state=false; println("Programmer not found.");connected_status=false;}
  myPort.write('i');
  delay(10);
  print("."); while (myPort.available() > 0)   val = myPort.readStringUntil('\n');
  if (val.contains("EEPROM")) {init_state=true; println("Programmer found.");connected_status=true;
   } 
   delay(100);
 
  }
  byte_count=0;
  }
                
 
