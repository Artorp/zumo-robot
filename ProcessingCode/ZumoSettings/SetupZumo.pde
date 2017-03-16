// This contains all code for the structure and methods on the setup zumo stage
void setupSetup(PApplet main) {
  // The root element of the setup page is a VBox
  VBox root = new VBox(0, 0, width, height, 0);
  stageSetup = new Stage(root, color(0));
  List<ShowableMargins> elements = new ArrayList<ShowableMargins>();
  
  
  float h = 100*u;
  float tm = 60*u;
  float bm = 80*u;
  TextArea title = new TextArea("Setup", width, h + tm + bm, tm, 10*u, bm);
  title.txtSize(60*u);
  elements.add(title);
  
  Button btn1 = new Button("Get Zumo Speed", width, defaultButtonHeight, 20*u, 20*u);
  btn1.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      println("TODO: Set up connection get code");
    }
  });
  elements.add(btn1);
  
  LabelValue labelSpeed = new LabelValue("Speed:", width, defaultButtonHeight, 20*u, 20*u);
  elements.add(labelSpeed);
  
  Slider sliderSpeed = new Slider(200, 0, 400, width, defaultButtonHeight, 20*u);
  labelSpeed.bind(sliderSpeed);
  elements.add(sliderSpeed);
  
  Button btn2 = new Button("Set Zumo Speed", width, defaultButtonHeight, 20*u, 20*u);
  btn2.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      println("TODO: Set up connection set code");
    }
  });
  elements.add(btn2);
  
  Button btn3 = new Button("Back", width, defaultButtonHeight, 20*u, 20*u);
  btn3.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      menu = Menu.MAIN;
    }
  });
  elements.add(btn3);
  
  root.addElements(elements);
}