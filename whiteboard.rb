#!/usr/bin/env ruby
require 'rubygems'
require 'Qt4'
require 'qrc_whiteboard'
require 'cwiid'
require 'mainwindow'
app = Qt::Application.new ARGV
unless Qt::SystemTrayIcon.isSystemTrayAvailable
  Qt::MessageBox.critical nil, 'System tray required',
    'Could not detect a system tray on this desktop'
end
window = MainWindow.new
window.show
app.exec
