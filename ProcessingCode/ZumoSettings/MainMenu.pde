// This contains all code for the structure and methods on the main menu

void setupMainMenu() {
  // stageMainMenu
  // The root element of the main menu is a VBox
  VBox root = new VBox(0, 0, width, height, 10*u); // TODO: Remove margin
  stageMainMenu = new Stage(root, color(100));
  Button btn1 = new Button("First", width, height, 5*u);
  List<ShowableMargins> mainMenuElements = new ArrayList<>();
}