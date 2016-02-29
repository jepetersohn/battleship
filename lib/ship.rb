# Ship class
class Ship
  attr_reader :location, :type, :xsize

  def initialize(matrix, options)
    @xsize    = options[:size]
    @type     = options[:type]
    @matrix   = matrix
    @location = Array.new
  end

  def build
    begin
      destroy
      ship_length = @xsize
      mask = Array.new
      # random start point
      while mask.empty?
        xy = rand(@matrix.size), rand(@matrix.size)
        mask = take_mask xy
      end
      save(xy)
      ship_length -= 1
      until ship_length.zero? || mask.size.zero?
        # random next direction
        xy = mask.delete_at(rand(mask.size))
        neighberhood = take_mask(xy, @location.last)
        next if neighberhood.empty?
        save xy
        mask = neighberhood
        ship_length -= 1
      end
    end until ship_length.zero?
    self
  end

  private

  def destroy
    @location.each { |xy| @matrix[xy[0]][xy[1]] = ' ' }
    @location = Array.new
  end

  def save(xy)
    @location.push xy
    @matrix[xy[0]][xy[1]] = true
  end

  # returns valid surrounding mask
  def take_mask(xy, exception = nil)
    return Array.new unless xy
    x = xy.first
    y = xy[1]
    return Array.new if @matrix[x][y]

    mask = Array.new

    mask[0] = [x - 1, y    ] if (x - 1) >= 0
    mask[1] = [x    , y - 1] if (y - 1) >= 0
    mask[2] = [x    , y + 1] if (y + 1) < @matrix.size
    mask[3] = [x + 1, y    ] if (x + 1) < @matrix.size
    clean mask, exception
  end

  def clean(mask, exception)
    mask.reject! { |item| item || item == exception }

    mask.each {|item| return Array.new if @matrix[item[0]][item[1]]}
    mask
  end
end
