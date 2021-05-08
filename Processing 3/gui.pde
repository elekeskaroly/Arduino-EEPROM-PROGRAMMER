String myString=""; 
 Textarea myTextarea;
 Textarea myTextarea2;
 Slider slider1;
 Button readbutton;
 Button writebutton;
 Button clearbutton;
 
 DropdownList connectDropList;
 DropdownList select;
 
 public void createcp5GUI()
    {

  cp5 = new ControlP5(this);
  
  myTextarea = cp5.addTextarea("txt")
                .setPosition(80,150)
                .setFont(createFont("Courier New", 13))
                .setLineHeight(18)
                .setColor(#000000)
                .setText("")
                .setSize(400,400)
                .enableColorBackground()
                .setColorBackground(color(#ffffff));           
  myTextarea2 = cp5.addTextarea("txt2")
                .setPosition(20,150)
                .setFont(createFont("Courier New", 13))
                .setLineHeight(18)
                .setColor(#000000)
                .hideScrollbar()
                .setText("")
                .setSize(59,400)
                .enableColorBackground()
                .setColorBackground(color(#f0fef0));           
              
                
 select= cp5.addDropdownList("selectlist")
                .setPosition(140, 20)
                .setCaptionLabel("Select EEPROM")
                .setItemHeight(20)
                .setBarHeight(20)
                .setSize(100,((eeproms.length+1)*20))
                .setOpen(false)
                .addItems(eeproms);
  
 connectDropList = cp5.addDropdownList("dropListConnect")
                .setPosition(20, 20)
                .setCaptionLabel("Select port")
                .setItemHeight(20)
                .setBarHeight(20)
                .setSize(100,(comPorts.size()+1)*20)
                .setOpen(false)
                .addItems(comPorts);
  
 slider1 = cp5.addSlider("sliderTicks1")
     .setPosition(10,560)
     .setSize(480,20)
     .setRange(0,epromsize)
     .setValue(0)
     .setLabelVisible(false)
     .setVisible(false)
     ;
  
  // and add another 2 buttons
  cp5.addButton("Load_file")
     .setBroadcast(false)
     .setValue(100)
     .setPosition(260,20) 
     .setSize(100,19)
     .setCaptionLabel("Open")
     .setBroadcast(true);
     
     
     cp5.addButton("Save_file")
     .setBroadcast(false)
     .setPosition(380,20)
     .setSize(100,19)
     .setValue(0)
     .setCaptionLabel("Save file")
     .setBroadcast(true);
     
 writebutton = cp5.addButton("Write_EEPROM")
     .setBroadcast(false)
     .setPosition(380,50)
     .setSize(100,19)
     .setValue(0)
     .setCaptionLabel("Write")
     .setBroadcast(true)
     ;
 
 readbutton = cp5.addButton("Read_EEPROM")
     .setBroadcast(false)
     .setPosition(260,50)
     .setSize(100,19)
     .setValue(0)
     .setCaptionLabel("Read EEPROM")
     .setBroadcast(true)
     ;

clearbutton = cp5.addButton("Clear_EEPROM")
     .setBroadcast(false)
     .setPosition(380,80)
     .setSize(100,19)
     .setValue(0)
     .setCaptionLabel("Erase")
     .setBroadcast(true)
     ;

 
     
     



    }
    



public void  Clear_EEPROM()
{
  
  
  
  if (connected_status){
 epromadress=0;step=0;
 byte_count=0;
 status_msg="Erasing...";
 delay(400);
 slider1.setVisible(true);
 eraseeeprom=!eraseeeprom;
 if (eraseeeprom==true) clearbutton.setCaptionLabel("Cancel");
 if (eraseeeprom==false) {clearbutton.setCaptionLabel("Erase");epromadress=0;slider1.setVisible(false);}
 
 
  }
 }
    
public void  Write_EEPROM()
{
  
  data1=myTextarea.getText();
  if (data1.length()<2) {writeeprom=false;println("nothing to write");}  
  else {
  
  if (connected_status){
 epromadress=0;step=0;byte_count=0;
 status_msg="Writing...";
 delay(400);
 slider1.setVisible(true);
 writeeprom=!writeeprom;
 if (writeeprom==true) writebutton.setCaptionLabel("Stop");
 if (writeeprom==false) {writebutton.setCaptionLabel("Write");epromadress=0;slider1.setVisible(false);}
 
 
  }
 }}
    
    
    
    
public void  Read_EEPROM()
{
  if (connected_status){
 epromadress=0;
 status_msg="Reading...";
 delay(400);
 slider1.setVisible(true);
 readeprom=!readeprom;
 String str2="";
 if (readeprom==true) readbutton.setCaptionLabel("Stop");
 if (readeprom==false) {readbutton.setCaptionLabel("Read EEPROM");epromadress=0;slider1.setVisible(false);}
 data1="";
 byte_count=0;}
 }

    
public void Load_file()
{
 selectInput("Select a file to process:", "fileSelected");
 openfile=true;
}

 
public void Save_file()
{
 selectOutput("Select a file to write to:", "fileSelected");
 savefile=true;
 

}




public void controlEvent(ControlEvent theEvent) {
 println(theEvent.getController().getName());
  
  
  
  
  
    if (theEvent.isController()) {
           

            if (("" + theEvent.getController()).contains("dropListConnect"))
            {
                Map m = connectDropList.getItem((int)theEvent.getController().getValue());
                        connect((String) m.get("name"));
            if (init_state==false & connected_status==true ) init();
                
            }
            
               if (("" + theEvent.getController()).contains("selectlist"))
            {
                Map m =select.getItem((int)theEvent.getController().getValue());
                       eeprom((String) m.get("name"));
            
                
            }
            
            
            
            
              }
            }

    
