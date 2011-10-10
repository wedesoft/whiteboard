require 'Qt4'
class CalibrateWidget < Qt::Widget
  SIZE = 20
  slots 'add_point(int,int)'
  signals 'step_changed(int)'
  signals 'finished()'
  signals 'aborted()'
  attr_reader :id
  attr_reader :point_pairs
  def initialize(parent = nil)
    super parent
    @id = 0
    @point_pairs = []
  end
  def marker
    [@id[0] == 1 ? width * 3 / 4 : width / 4, @id[1] == 1 ? height * 3 / 4: height / 4]
  end
  def paintEvent(e)
    super e
    x, y = *marker
    p = Qt::Painter.new self
    p.translate x, y
    pen = Qt::Pen.new Qt::Color.new(255, 0, 0)
    pen.width = 3
    p.pen = pen
    p.drawLine -SIZE, 0, SIZE, 0
    p.drawLine 0, -SIZE, 0, SIZE
    p.drawEllipse -SIZE, -SIZE, 2 * SIZE + 1, 2 * SIZE + 1
    p.end
  end
  def keyPressEvent(e)
    if e.key == Qt::Key_Escape
      emit aborted
      close
    end
  end
  def add_point(x, y)
    @point_pairs += [[[x, y], marker]]
    @id += 1
    if @id < 4
      emit step_changed(@id)
      update
    else
      emit finished
      close
    end
  end
end

