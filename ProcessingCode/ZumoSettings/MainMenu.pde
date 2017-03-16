// This contains all code for the structure and methods on the main menu

void setupMainMenu() {
  // stageMainMenu
  // The root element of the main menu is a VBox
  VBox root = new VBox(0, 0, width, height, 10*u); // TODO: Remove margin on root element
  stageMainMenu = new Stage(root, color(100));
  Button btn1 = new Button("First", width, defaultButtonHeight, 5*u, 20*u);
  Button btn2 = new Button("Second", width, defaultButtonHeight, 5*u, 20*u);
  List<ShowableMargins> elements = new ArrayList<ShowableMargins>();
  elements.add(btn1);
  elements.add(btn2);
  root.addElements(elements);
}