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
  
  ShowableMarginsImpl(float x, float y, float w, float h, float hMargin, float vMargin) {
    this(x, y, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  ShowableMarginsImpl(float x, float y, float w, float h, float margin) {
    this(x, y, w, h, margin, margin, margin, margin);
  }
  
  
  @Override public void show() {
    if (debugShowBounding) {
      // DEBUG: Show our own bounding box
      pushStyle();
      
      fill(#C4557C);
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
    this.elements = new ArrayList();
    
    xPencil = x;
    yPencil = y;
  }
  
  VBox(float x, float y, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading, call our most parameterized constructor
    this(x, y, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  VBox(float x, float y, float w, float h, float hMargin, float vMargin) {
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
      this.yPencil += Math.max(prevBottomMargin, element.getTopMargin()); // Make sure margins can overlap
      element.setX(this.xPencil + element.getLeftMargin()); // This is a VBox, x is always ( our x + leftMargin )
      element.setY(this.yPencil);
      this.yPencil += element.getHeight();
    }
    this.elements.addAll(elements);
  }
}

class Button extends ShowableMarginsImpl {
  
  String text;
  
  Button(String text, float w, float h, float topMargin, float rightMargin, float bottomMargin, float leftMargin) {
    super(0, 0, w, h, topMargin, rightMargin, bottomMargin, leftMargin);
    this.text = text;
  }
  
  Button(String text, float x, float y, float w, float h, float topMargin, float sideMargins, float bottomMargin) {
    // Constructor overloading, call our most parameterized constructor
    this(text, w, h, topMargin, sideMargins, bottomMargin, sideMargins);
  }
  
  Button(String text, float w, float h, float hMargin, float vMargin) {
    this(text, w, h, vMargin, hMargin, vMargin, hMargin);
  }
  
  Button(String text, float w, float h, float margin) {
    this(text, w, h, margin, margin, margin, margin);
  }
  
  @Override public void show() {
    // Render our text:
    noStroke();
    fill(255);
    textAlign(CENTER);
    textSize(defaultButtonTextSize);
    text(text, x + w / 2, y + h / 2);
  }
}