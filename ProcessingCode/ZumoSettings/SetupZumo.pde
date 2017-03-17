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
  
  final LabelValue labelSpeed = new LabelValue("Speed:", width, defaultButtonHeight, 20*u, 20*u);
  
  Button btn1 = new Button("Get Zumo Speed", width, defaultButtonHeight, 20*u, 20*u){
    @Override public void show() {
      if (disabled == isConnected) {
        this.setDisabled(!isConnected);
      }
      super.show();
    }
  };
  btn1.setDisabled(isConnected);
  elements.add(btn1);
  
  
  elements.add(labelSpeed);
  
  final Slider sliderSpeed = new Slider(200, 0, 400, width, defaultButtonHeight, 20*u);
  labelSpeed.bind(sliderSpeed);
  elements.add(sliderSpeed);
  
  Button btn2 = new Button("Set Zumo Speed", width, defaultButtonHeight, 20*u, 20*u){
    @Override public void show() {
      if (disabled == isConnected) {
        this.setDisabled(!isConnected);
      }
      super.show();
    }
  };
  btn2.setDisabled(isConnected);
  elements.add(btn2);
  
  Button btn3 = new Button("Back", width, defaultButtonHeight, 20*u, 20*u);
  elements.add(btn3);
  
  // On Action elements
  // Get Zumo speed
  btn1.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      BTListener getZumoSpeed = new BTListener(){
        @Override public void sendMessage(String msg) {
          if (msg.startsWith("SPEED IS ")) {
            int speed = Integer.parseInt(msg.substring(9));
            sliderSpeed.setValue(speed);
          } else {
            println("Failed to received message, expected \"SPEED IS \" but got "+msg);
          }
          btListeners.remove(this);
        }
      };
      btListeners.add(getZumoSpeed);
      String toSend = "GETSPEED\r\n";
      byte[] data = toSend.getBytes(Charset.forName("UTF-8"));
      bt.broadcast(data);
    }
  });
  
  // Set new Zumo speed
  btn2.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      BTListener setZumoSpeed = new BTListener(){
        @Override public void sendMessage(String msg) {
          if (msg.startsWith("OK NEW SPEED SET")) {
            // Good
          } else {
            println("Failed to received message, expected \"OK NEW SPEED SET\" but got "+msg);
          }
          btListeners.remove(this);
        }
      };
      btListeners.add(setZumoSpeed);
      int newSpeed = (int) sliderSpeed.getValue();
      String toSend = "SETSPEED "+newSpeed+"\r\n";
      byte[] data = toSend.getBytes(Charset.forName("UTF-8"));
      bt.broadcast(data);
    }
  });
  
  // Back
  btn3.setOnAction(new FunctionOnAction(){
    @Override public void apply() {
      menu = Menu.MAIN;
    }
  });
  
  root.addElements(elements);
}