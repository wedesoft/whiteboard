require 'Qt4'
require 'ui_mainwindow'
require 'calibratewidget'
require 'homography'
require 'cwiid'
require 'x11test'
class MainWindow < Qt::MainWindow
  DELAY = 5000
  slots 'wiimote(bool)'
  slots 'calibrate()'
  slots 'calib_step(int)'
  slots 'calib_finish()'
  slots 'calib_abort()'
  slots 'tray(QSystemTrayIcon::ActivationReason)'
  signals 'ir_clicked(int,int)'
  signals 'ir_released()'
  def initialize(parent = nil)
    super parent
    @ui = Ui::MainWindow.new
    @ui.setupUi self
    tray_menu = Qt::Menu.new self do |t|
      t.addAction @ui.action_connect
      t.addAction @ui.action_calibrate
      t.addSeparator
      t.addAction @ui.action_quit
    end
    @tray = Qt::SystemTrayIcon.new self
    @tray.contextMenu = tray_menu
    @tray.icon = windowIcon
    connect @ui.action_connect, SIGNAL('toggled(bool)'), self, SLOT('wiimote(bool)')
    connect @ui.action_calibrate, SIGNAL('triggered()'), self, SLOT('calibrate()')
    connect @ui.action_quit, SIGNAL('triggered()'), $qApp, SLOT('quit()')
    connect @tray, SIGNAL('activated(QSystemTrayIcon::ActivationReason)'),                   
      self, SLOT('tray(QSystemTrayIcon::ActivationReason)')
    @tray.show
    @wiimote = nil
    @timer = 0
    @state = false
    @calibration = nil
    @homography = nil
  end
  def wiimote(on)
    begin
      default = cursor
      setCursor Qt::Cursor.new(Qt::WaitCursor)
      if on
        @wiimote = WiiMote.new
        @wiimote.rpt_mode = WiiMote::RPT_BTN | WiiMote::RPT_IR
        @ui.action_calibrate.enabled = true
        @timer = startTimer 0
        @tray.showMessage windowTitle, 'Established Bluetooth connection to Wii remote',
          Qt::SystemTrayIcon::Information, DELAY
      elsif @wiimote
        @ui.action_calibrate.enabled = false
        killTimer @timer
        @homography = nil
        @calibration = nil
        @state = false
        @timer = 0
        @wiimote.close
        @wiimote = nil
        @tray.showMessage windowTitle, 'Dropped connection to Wii Remote',
          Qt::SystemTrayIcon::Information, DELAY
      end
      setCursor default
    rescue Exception => e
      setCursor default
      @tray.showMessage windowTitle, e.message, Qt::SystemTrayIcon::Critical, DELAY
      @ui.action_connect.checked = false
    end
  end
  def timerEvent(e)
    led_next = Time.new.sec % 4
    @wiimote.get_state
    pos = @wiimote.ir.size > 0 ? @wiimote.ir.sort_by { |x,y,r| r }.last : nil
    if pos and @homography
      screen = @homography.transform pos[0], pos[1]
      fake_motion_event screen[0].to_i, screen[1].to_i, 0
    end
    if pos.nil? == @state
      @state = !@state
      if @state
        if @homography
          fake_button_event 1, true, 0
        else
          emit ir_clicked(pos[0], pos[1])
        end
      else
        if @homography
          fake_button_event 1, false, 0
        else
          emit ir_released
        end
      end
    end
  end
  def closeEvent(e)
    if @tray.visible?
      message = <<EOS
The application will continue to run in the system tray.
To terminate the program right-click on the tray icon and
choose Quit in the context menu.
EOS
      @tray.showMessage windowTitle, message, Qt::SystemTrayIcon::Information, DELAY
      hide
      e.ignore
    end
  end
  def calibrate
    @homography = nil
    @calibration = CalibrateWidget.new
    flags = Qt::Enum.new 0, 'Qt::WindowFlags'
    #flags |= Qt::DialogType
    #flags |= Qt::FramelessWindowHint
    #@calibration.windowFlags = flags
    #@calibration.setWindowFlags(Qt::FramelessWindowHint || Qt::DialogType)
    @calibration.setWindowFlags(Qt::FramelessWindowHint || Qt::DialogType)
    @calibration.cursor = Qt::Cursor.new Qt::BlankCursor
    connect @ui.action_quit, SIGNAL('triggered()'), self, SLOT('close()')
    connect self, SIGNAL('ir_clicked(int,int)'), @calibration, SLOT('add_point(int,int)')
    connect @calibration, SIGNAL('step_changed(int)'), self, SLOT('calib_step(int)')
    connect @calibration, SIGNAL('finished()'), self, SLOT('calib_finish()')
    connect @calibration, SIGNAL('aborted()'), self, SLOT('calib_abort()')
    @calibration.showFullScreen
    @wiimote.led = 1 << @calibration.id
  end
  def calib_step(step)
    @wiimote.led = 1 << step
  end
  def calib_finish
    @wiimote.led = 0
    disconnect self, nil, @calibration, nil
    @homography = Homography.new *@calibration.point_pairs
    @tray.showMessage windowTitle, 'Wii remote whiteboard was calibrated',
      Qt::SystemTrayIcon::Information, DELAY
  end
  def calib_abort
    disconnect self, nil, @calibration, nil
    @wiimote.led = 0
    @tray.showMessage windowTitle, 'Calibration was aborted',
      Qt::SystemTrayIcon::Information, DELAY
  end
  def tray(reason)
    if reason == Qt::SystemTrayIcon::Trigger
      if visible?
        hide
      else
        show
      end
    end
  end
end

