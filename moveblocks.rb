#!/usr/bin/env ruby
require 'rubygems'
require 'Qt4'
class Screen < Qt::GraphicsView
  def initialize(scene, parent = nil)
    super scene, parent
    flags = Qt::Enum.new 0, 'Qt::WindowFlags'
    flags |= Qt::DialogType
    flags |= Qt::FramelessWindowHint
    window.windowFlags = flags
  end
end
class Item < Qt::GraphicsSvgItem
  def initialize(file_name, parent = nil)
    super file_name, parent
    setFlag ItemIsMovable
  end
end
app = Qt::Application.new ARGV
desktop = Qt::Application.desktop
width, height = desktop.width / 2, desktop.height / 2
scene = Qt::GraphicsScene.new 0, 0, width, height
window = Screen.new scene
files = Dir.glob '*.svg'
for i in 0 .. 9
  test = Item.new files[rand(files.size)]
  test.setPos rand(width), rand(height)
  scene.addItem test
end
window.showFullScreen
app.exec

