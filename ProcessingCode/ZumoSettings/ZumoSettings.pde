import java.util.List;
import java.util.ArrayList;
import java.nio.charset.Charset;
import android.content.Intent;
import android.os.Bundle;
import ketai.ui.*;
import ketai.net.bluetooth.*;


// Globals
boolean debugShowBounding = false;
float u; // Scalable pixel unit depending on size, think "rem" from CSS, defaults to 2 px on a 1080px width
float defaultButtonTextSize;
float defaultButtonHeight;
PFont myFont;

// Stages:
Stage stageMainMenu;
Stage stageSetup;

// Active menu:
enum Menu {
  MAIN,
  SETUP
}
Menu menu = Menu.MAIN; // The global stage choice

// Bluetooth variables
KetaiBluetooth bt;
boolean isConfiguring = false; // Wait with configuring until button is pressed
KetaiList klist;
StringBuilder strInput = new StringBuilder("");
List<BTListener> btListeners = new ArrayList<BTListener>();

// Required for bluetooth connection
void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  bt = new KetaiBluetooth(this);
}

void onActivityResult(int requestCode, int resultCode, Intent data) {
  bt.onActivityResult(requestCode, resultCode, data);
}


void setup() {
  //size(540, 960); // Nexus 5x half dimentions, only to be used in java mode, use fullScreen() in Android mode
  fullScreen();
  u = floor(width/540);
  defaultButtonTextSize = 46*u;
  defaultButtonHeight = 120*u;
  // Actual dims: x:1080, y:1920 (portrait)
  orientation(PORTRAIT);
  
  // frameRate(30);
  myFont = createFont("Monospaced-Bold", 14);
  textFont(myFont);
  
  // Start listening for bluetooth connections
  bt.start();
  // On app start select device
  isConfiguring = true;
  
  setupMainMenu(this);
  setupSetup(this);
}

void draw() {
  background(0);
  if (menu == Menu.MAIN) {
    if (stageMainMenu != null) {
      stageMainMenu.show();
    }
  } else if (menu == Menu.SETUP) {
    if (stageSetup != null) {
      stageSetup.show();
    }
  }
}

void onKetaiListSelection(KetaiList klist) {
  String selection = klist.getSelection();
  bt.connectToDeviceByName(selection);
  //dispose of list for now
  klist = null;
}

// Callback method to manage data received
void onBluetoothDataEvent(String who, byte[] data) {
  if (isConfiguring)
    return;
  // Received
  
  // Using char '|' as end-of-file
  
  for (int i = 0; i < data.length; i++) {
    char c = (char) data[i];
    if ( c == '|') {
      String message = new String(strInput);
      strInput = new StringBuilder("");
      btMessageReceived(message);
      continue;
    }
    strInput.append(c);
  }
  
  //String recv = new String(data, Charset.forName("UTF-8"));
}

void btMessageReceived(String msg) {
  println("Message received: "+msg);
  for (BTListener listener : btListeners) {
    listener.sendMessage(msg);
  }
}