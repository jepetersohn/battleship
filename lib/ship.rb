class Ship
  attr_reader :location, :type, :xsize

  def initialize(matrix, options)
    @xsize    = options[:size]
    @type     = options[:type]
    @matrix   = matrix
    @location = []
  end

  def build
    begin
      destroy
      ship_len = @xsize
      mask = []
      # random start point
      begin
        xy = [rand(@matrix.size), rand(@matrix.size)]
        mask = take_mask(xy)
      end while mask.empty?
      save(xy)
      ship_len -= 1
      while (!ship_len.zero? && !mask.size.zero?)
        # random next direction
        xy = mask.delete_at(rand(mask.size))
        neighberhood = take_mask(xy, @location.last)
        unless neighberhood.empty?
          save(xy)
          mask = neighberhood
          ship_len -= 1
        end
      end
    end while !ship_len.zero?
    self
  end

  private

  def destroy
    @location.each { |xy| @matrix[xy[0]][xy[1]] = ' ' }
    @location = []
  end

  def save(xy)
    @location.push(xy)
    @matrix[xy[0]][xy[1]] = true
  end

  # returns valid surrounding mask
  def take_mask(xy, exception = nil)
    return [] unless xy
    x = xy[0]
    y = xy[1]
    return [] if @matrix[x][y] === true

    mask = []

    mask[0] = [x - 1, y    ] if (x - 1) >= 0
    mask[1] = [x,     y - 1] if (y - 1) >= 0
    mask[2] = [x,     y + 1] if (y + 1) < @matrix.size
    mask[3] = [x + 1, y    ] if (x + 1) < @matrix.size
    clean(mask, exception)
  end

  def clean(mask, exception)
    mask = mask.select { |item| item && item != exception }

    mask.each do |item|
      return [] if @matrix[item[0]][item[1]] == true
    end
    mask
  end
end
