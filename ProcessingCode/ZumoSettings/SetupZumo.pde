// This contains all code for the structure and methods on the setup zumo stage
void setupSetup() {
  // The root element of the setup page is a VBox
  VBox root = new VBox(0, 0, width, height, 10*u); // TODO: Remove margin on root element
  stageSetup = new Stage(root, color(100));
  List<ShowableMargins> elements = new ArrayList<ShowableMargins>();
  
  TextArea title = new TextArea("Change Zumo Settings", width, 300*u + 100*u, 60*u, 10*u, 100*u);
  title.strokeColor(color(#8E7F10)).txtSize(40*u);
  elements.add(title);
  
  Button btn1 = new Button("Get Zumo Speed", width, defaultButtonHeight, 20*u, 20*u);
  btn1.setTextSize(36*u);
  elements.add(btn1);
  
  LabelValue labelSpeed = new LabelValue("Speed:", width, defaultButtonHeight, 20*u, 20*u);
  elements.add(labelSpeed);
  
  Slider sliderSpeed = new Slider(200, 0, 400, width, defaultButtonHeight, 20*u);
  elements.add(sliderSpeed);
  
  Button btn2 = new Button("Set Zumo Speed", width, defaultButtonHeight, 20*u, 20*u);
  elements.add(btn2);
  
  Button btn3 = new Button("Back", width, defaultButtonHeight, 20*u, 20*u);
  elements.add(btn3);
  
  root.addElements(elements);
}