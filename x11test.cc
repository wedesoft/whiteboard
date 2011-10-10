#include <X11/X.h>
#include <X11/extensions/XTest.h>
#include <ruby.h>

VALUE wrapFakeButtonEvent(VALUE rbSelf, VALUE rbButton, VALUE rbPress,
                          VALUE rbDelay)
{
  Display *display = XOpenDisplay(NULL);
  XTestFakeButtonEvent(display, NUM2INT(rbButton),
                       rbPress != Qfalse ? True : False, NUM2INT(rbDelay));
  XCloseDisplay(display);
  return rbSelf;
}

VALUE wrapFakeMotionEvent(VALUE rbSelf, VALUE rbX, VALUE rbY, VALUE rbDelay)
{
  Display *display = XOpenDisplay(NULL);
  XTestFakeMotionEvent(display, DefaultScreen(display),
                       NUM2INT(rbX), NUM2INT(rbY), NUM2INT(rbDelay));
  XCloseDisplay(display);
  return rbSelf;
}

extern "C" {

  void Init_x11test(void)
  {
    rb_define_method(rb_cObject, "fake_button_event",
                     RUBY_METHOD_FUNC(wrapFakeButtonEvent), 3);
    rb_define_method(rb_cObject, "fake_motion_event",
                     RUBY_METHOD_FUNC(wrapFakeMotionEvent), 3);
  }

}
