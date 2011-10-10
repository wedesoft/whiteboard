require 'matrix'
require 'linalg'
include Linalg
class Matrix
  def to_dmatrix
    DMatrix[*to_a]
  end
  def svd
    to_dmatrix.svd.collect { |m| m.to_matrix }
  end
end
class Vector
  def reshape(w, h)
    Matrix[*(0 ... h).collect { |i| to_a[i * w ... i.succ * w] }]
  end
end
class DMatrix
  def to_matrix
    Matrix[*to_a]
  end
end
class Homography
  def initialize(*pairs)
    constraints = []
    pairs.each do |p,ps|
      constraints.push [p[0].to_f, p[1].to_f, 1.0, 0.0, 0.0, 0.0,
                        -ps[0].to_f * p[0].to_f, -ps[0].to_f * p[1].to_f, -ps[0].to_f]
      constraints.push [0.0, 0.0, 0.0, p[0].to_f, p[1].to_f, 1.0,
                        -ps[1].to_f * p[0].to_f, -ps[1].to_f * p[1].to_f, -ps[1].to_f]
    end
    @matrix = Matrix[*constraints].svd[2].row(8).reshape 3, 3
  end
  def transform(x, y)
    p = Vector[x.to_f, y.to_f, 1.0]
    ps = @matrix * p
    [ps[0] / ps[2], ps[1] / ps[2]]
  end
end

