import java.util.List;
import java.util.ArrayList;

// Globals
boolean debugShowBounding = true;
float u; // Scalable pixel unit depending on size, think "rem" from CSS, defaults to 2 px on a 1080px width
float defaultButtonTextSize;
float defaultButtonHeight;

// Stages:
Stage stageMainMenu;
Stage stageSetup;

// Active menu:
enum Menu {
  MAIN,
  SETUP
}
Menu menu = Menu.SETUP; // The 


void setup() {
  size(540, 960); // Nexus 5x half dimentions, only to be used in java mode, use fullScreen() in Android mode
  u = floor(width/540);
  defaultButtonTextSize = 50*u;
  defaultButtonHeight = 120*u;
  // Actual dims: x:1080, y:1920 (portrait)
  orientation(PORTRAIT);
  
  setupMainMenu();
  setupSetup();
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