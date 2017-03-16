interface ShowableMargins {
  public void show(); // Called every draw frame
  public float getTopMargin();
  public float getRightMargin();
  public float getBottomMargin();
  public float getLeftMargin();
  public float getWidth();
  public float getHeight();
  public float setMaxWidth(float w);
  public float setMaxHeight(float h);
  public void setX(float x);
  public void setY(float y);
}

interface Container {
  public void addElements(List<ShowableMargins> elements);
}

/*
* The stage represents a menu on the app, it renders every element within
*/
class Stage {
  
  color bc;
  ShowableMargins root;
  
  
  Stage(ShowableMargins root, color bc) {
    // This is the stage constructor
    this.bc = bc;
    root.setX(root.getLeftMargin());
    root.setY(root.getTopMargin());
    root.setMaxWidth(width);
    root.setMaxHeight(height);
    this.root = root;
  }
  
  public void show() {
    // draw background:
    fill(bc);
    noStroke();
    rect(0, 0, width, height);
    // Call our root
    root.show();
  }
}

/*
* The ShowableMarginsImpl class is the basic class all other margin objects inherit.
* Implemented like this to avoid repeated code.
*/
class ShowableMarginsImpl implements ShowableMargins {
  
  protected float x;
  protected float y;
  protected float w;
  protected float h;
  protected float topMargin;
  protected float rightMargin;
  protected float bottomMargin;
  protected float leftMargin;
  
  private ShowableMarginsImpl() {
    // Default constructor, note, it is private and should not be used explicitly
    // but instead be called from other constructors where applicable
  }
  
  // Note, w and h are reduced by the hMargin and vMargin, this is similar to CSS "box-sizing: border-box"
  ShowableMarginsImpl(float x, float y, float w, float h, float topMargin, float rightMargin, float bottomMargin, float leftMargin) {
    this();
    // This is the most parameterized constructor, all other constructors should call this one
    this.x = x + leftMargin;
    this.y = y + topMargin;
    this.w = w - (leftMargin + rightMargin);
    this.h = h - (topMargin + bottomMargin);
    this.topMargin = topMargin;
    this.rightMargin = rightMargin;
    this.bottomMargin = bottomMargin;
    this.leftMargin = leftMargin;
  }
  
  ShowableMarginsImpl(float x, float y, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading
    // Call our most parameterized constructor
    this(x, y, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  ShowableMarginsImpl(float x, float y, float w, float h, float vMargin, float hMargin) {
    this(x, y, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  ShowableMarginsImpl(float x, float y, float w, float h, float margin) {
    this(x, y, w, h, margin, margin, margin, margin);
  }
  
  
  @Override public void show() {
    if (debugShowBounding) {
      // DEBUG: Show our own bounding box
      pushStyle();
      
      fill(#D67CFA);
      stroke(0, 255, 0);
      rect(x, y, w, h);
      
      popStyle();
    }
  }
  
  @Override public float getTopMargin()    { return topMargin; }
  @Override public float getRightMargin()  { return rightMargin; }
  @Override public float getBottomMargin() { return bottomMargin; }
  @Override public float getLeftMargin()   { return leftMargin; }
  @Override public float getWidth()        { return w; }
  @Override public float getHeight()       { return h; }
  @Override public float setMaxWidth(float w) {
    this.w = Math.min(w - (leftMargin + rightMargin), this.w);
    return this.w;
  }
  @Override public float setMaxHeight(float h) {
    this.h = Math.min(h - (topMargin + bottomMargin), this.h);
    return this.h;
  }
  @Override public void setX(float x) { this.x = x; }
  @Override public void setY(float y) { this.y = y; }
  
}

class VBox extends ShowableMarginsImpl implements Container {
  
  List<ShowableMargins> elements;
  
  // Used to add elements to a container:
  float xPencil;
  float yPencil;
  
  
  // Note, w and h are reduced by the hMargin and vMargin, this is similar to CSS "box-sizing: border-box"
  VBox(float x, float y, float w, float h, float topMargin, float rightMargin, float bottomMargin, float leftMargin) {
    super(x, y, w, h, topMargin, rightMargin, bottomMargin, leftMargin);
    // This is the most parameterized constructor
    this.elements = new ArrayList<ShowableMargins>();
    
    xPencil = this.x;
    yPencil = this.y;
  }
  
  VBox(float x, float y, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading, call our most parameterized constructor
    this(x, y, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  VBox(float x, float y, float w, float h, float vMargin, float hMargin) {
    this(x, y, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  VBox(float x, float y, float w, float h, float margin) {
    this(x, y, w, h, margin, margin, margin, margin);
  }
  
  
  @Override public void show() {
    super.show();
    // Render all elements within this box
    for (ShowableMargins e : this.elements) {
      e.show();
    }
  }
  
  @Override public void addElements(List<ShowableMargins> elements) {
    // This method will change elements' width and height to fit this container, and then add them
    int len = elements.size();
    for (int i = 0; i < len; i++) {
      // Using indexed for loop as we'll need to reference previous element to check margins
      ShowableMargins element = elements.get(i);
      element.setMaxWidth(this.w); // All elements in a VBox have a max width of the VBox
      
      // Handle margins
      float prevBottomMargin = 0;
      // Is there a previous element?
      if ((i - 1) >= 0) {
        ShowableMargins prevElement = elements.get(i - 1);
        prevBottomMargin = prevElement.getBottomMargin();
      }
      yPencil += Math.max(prevBottomMargin, element.getTopMargin()); // Make sure margins can overlap
      element.setX(this.xPencil + element.getLeftMargin()); // This is a VBox, x is always ( our x + leftMargin )
      element.setY(this.yPencil);
      yPencil += element.getHeight();
    }
    this.elements.addAll(elements);
  }
}

class Button extends ShowableMarginsImpl {
  
  String text;
  float txtSize;
  
  Button(String text, float w, float h, float topMargin, float rightMargin, float bottomMargin, float leftMargin) {
    super(0, 0, w, h, topMargin, rightMargin, bottomMargin, leftMargin);
    this.text = text;
    this.txtSize = defaultButtonTextSize;
  }
  
  Button(String text, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading, call our most parameterized constructor
    this(text, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  Button(String text, float w, float h, float vMargin, float hMargin) {
    this(text, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  Button(String text, float w, float h, float margin) {
    this(text, w, h, margin, margin, margin, margin);
  }
  
  public Button setTextSize(float size) {
    txtSize = size;
    return this;
  }
  
  @Override public void show() {
    // Render button:
    stroke(#1E78E3);
    fill(0);
    rect(x, y, w, h);
    // Render our text:
    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(txtSize);
    text(text, x + w / 2, y + h / 2 - txtSize*0.15);
  }
}

class TextArea extends ShowableMarginsImpl {
  
  String text;
  color fillColor;
  color strokeColor;
  color textColor;
  float textSize;
  
  TextArea(String text, float w, float h, float topMargin, float rightMargin, float bottomMargin, float leftMargin) {
    super(0, 0, w, h, topMargin, rightMargin, bottomMargin, leftMargin);
    this.text = text;
    this.fillColor = -1;
    this.strokeColor = -1;
    this.textColor = color(255);
    this.textSize = defaultButtonTextSize;
  }
  
  TextArea(String text, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading, call our most parameterized constructor
    this(text, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  TextArea(String text, float w, float h, float vMargin, float hMargin) {
    this(text, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  TextArea(String text, float w, float h, float margin) {
    this(text, w, h, margin, margin, margin, margin);
  }
  
  public TextArea fillColor(color fill) {
    this.fillColor = fill;
    return this;
  }
  
  public TextArea strokeColor(color s) {
    this.strokeColor = s;
    return this;
  }
  
  public TextArea textColor(color t) {
    this.fillColor = t;
    return this;
  }
  
  public TextArea txtSize(float size) {
    this.textSize = size;
    return this;
  }
  
  @Override public void show() {
    // Render area:
    if (strokeColor != -1) {
      stroke(strokeColor);
    } else {
      noStroke();
    }
    if (fillColor != -1) {
      fill(fillColor);
    } else {
      noFill();
    }
    if (strokeColor != -1 || fillColor != -1) {
      rect(x, y, w, h);
    }
    // Render our text:
    noStroke();
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(textSize);
    text(text, x + w / 2, y + h / 2 - textSize*0.15);
  }
}

class LabelValue extends ShowableMarginsImpl {
  
  String text;
  float value;
  float txtSize;
  
  LabelValue(String text, float w, float h, float topMargin, float rightMargin, float bottomMargin, float leftMargin) {
    super(0, 0, w, h, topMargin, rightMargin, bottomMargin, leftMargin);
    this.text = text;
    this.value = 0;
    this.txtSize = defaultButtonTextSize;
  }
  
  LabelValue(String text, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading, call our most parameterized constructor
    this(text, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  LabelValue(String text, float w, float h, float vMargin, float hMargin) {
    this(text, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  LabelValue(String text, float w, float h, float margin) {
    this(text, w, h, margin, margin, margin, margin);
  }
  
  public LabelValue setTextSize(float size) {
    txtSize = size;
    return this;
  }
  
  public void setValue(float v) {
    this.value = v;
  }
  
  @Override public void show() {
    // Render our text:
    noStroke();
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(txtSize);
    text(text, x, y + h / 2 - txtSize*0.15);
    textAlign(RIGHT, CENTER);
    text(int(value), x + w, y + h / 2 - txtSize*0.15);
  }
}

class Slider extends ShowableMarginsImpl {
  float value;
  float maxVal;
  float minVal;
  float box_y; // Center
  float box_x; // Center
  float box_s; // Horizontal and vertical size
  boolean lock;
  
  Slider(float val, float minVal, float maxVal, float w, float h, float topMargin, float rightMargin, float bottomMargin, float leftMargin) {
    super(0, 0, w, h, topMargin, rightMargin, bottomMargin, leftMargin);
    this.value = val;
    this.minVal = minVal;
    this.maxVal = maxVal;
    box_s = 60*u;
  }
  
  Slider(float val, float minVal, float maxVal, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading, call our most parameterized constructor
    this(val, minVal, maxVal, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  Slider(float val, float minVal, float maxVal, float w, float h, float vMargin, float hMargin) {
    this(val, minVal, maxVal, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  Slider(float val, float minVal, float maxVal, float w, float h, float margin) {
    this(val, minVal, maxVal, w, h, margin, margin, margin, margin);
  }
  
  private float calcBoxX() {
    float return_x = map(value, minVal, maxVal, x + box_s / 2, x + w - box_s/2);
    return return_x;
  }
  
  public float getValue() {
    float return_val = box_x;
    map(return_val, x + box_s/2, x + w - box_s/2, minVal, maxVal);
    return return_val;
  }
  
  @Override public void setX(float x) {
    super.setX(x);
    box_x = calcBoxX();
  }
  
  @Override public void setY(float y) {
    super.setY(y);
    box_y = y + h/2;
  }
  
  @Override public void show() {
    // Render the lines:
    pushStyle();
    noFill();
    stroke(255);
    strokeWeight(4);
    line(x, y, x, y + h);
    line(x + w, y, x + w, y + h);
    strokeCap(SQUARE);
    line(x, y + h/2, x + w, y + h/2);
    popStyle();
    
    // Render the box:
    pushStyle();
    
    stroke(0);
    fill(180);
    rect(box_x - box_s / 2, box_y - box_s / 2, box_s, box_s);
    
    popStyle();
    
  }
}