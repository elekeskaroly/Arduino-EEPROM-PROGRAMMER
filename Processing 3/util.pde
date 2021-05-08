String[] eeproms={"AT28C64B", "CAT28LV65P" ,"AT27C256R"};

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");file_event=false;
  } else {
    println("User selected " + selection.getAbsolutePath());
    sfilename=selection.getAbsolutePath();
    file_event=true;
  }
}

void eeprom(String etype)
{
  if (etype.equals("AT28C64B")) epromsize=0x1F40;
  if (etype.equals("CAT28LV65P")) epromsize=0x1F40;
  if (etype.equals("AT27C256R")) epromsize=0xFFFF;
  slider1.setRange(0,epromsize);
  
}
