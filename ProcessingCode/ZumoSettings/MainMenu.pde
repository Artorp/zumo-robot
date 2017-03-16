// This contains all code for the structure and methods on the main menu

void setupMainMenu() {
  // stageMainMenu
  // The root element of the main menu is a VBox
  VBox root = new VBox(0, 0, width, height, 10*u); // TODO: Remove margin on root element
  stageMainMenu = new Stage(root, color(100));
  TextArea title = new TextArea("Zumo Settings", width, 300*u + 200*u, 60*u, 10*u, 200*u);
  title.strokeColor(color(#8E7F10)).txtSize(60*u);
  Button btn1 = new Button("Connect to paired device", width, defaultButtonHeight, 20*u, 20*u);
  btn1.setTextSize(36*u);
  Button btn2 = new Button("Setup Zumo", width, defaultButtonHeight, 20*u, 20*u);
  Button btn3 = new Button("About", width, defaultButtonHeight, 20*u, 20*u);
  List<ShowableMargins> elements = new ArrayList<ShowableMargins>();
  elements.add(title);
  elements.add(btn1);
  elements.add(btn2);
  elements.add(btn3);
  root.addElements(elements);
}