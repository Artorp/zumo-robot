// This contains all code for the structure and methods on the main menu

void setupMainMenu(PApplet main) {
  final PApplet mn = main;
  // The root element of the main menu is a VBox
  VBox root = new VBox(0, 0, width, height, 0);
  stageMainMenu = new Stage(root, color(0)){
    @Override public void show() {
      if (isConfiguring) {
        // Connect to bluetooth stuff
        klist = new KetaiList(mn, bt.getPairedDeviceNames());
        isConfiguring = false;
      }
      super.show();
    }
  };
  
  List<ShowableMargins> elements = new ArrayList<ShowableMargins>();
  
  float h = 100*u;
  float tm = 60*u;
  float bm = 80*u;
  TextArea title = new TextArea("Zumo Settings", width, h + tm + bm, tm, 10*u, bm);
  title.txtSize(60*u);
  elements.add(title);
  
  Button btn1 = new Button("Connect to paired device", width, defaultButtonHeight, 20*u, 20*u);
  btn1.setTextSize(32*u);
  btn1.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      isConfiguring = true;
    }
  });
  elements.add(btn1);
  
  Button btn2 = new Button("Setup Zumo", width, defaultButtonHeight, 20*u, 20*u);
  btn2.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      menu = Menu.SETUP;
    }
  });
  elements.add(btn2);
  
  Button btn3 = new Button("About", width, defaultButtonHeight, 20*u, 20*u);
  btn3.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      KetaiAlertDialog.popup(mn, "About Zumo Settings", "Zumo Settings v1.0\n\nAuthor: Thomas Bruvold\nGroup Project PLab Spring 2017");
    }
  });
  elements.add(btn3);
  
  root.addElements(elements);
}