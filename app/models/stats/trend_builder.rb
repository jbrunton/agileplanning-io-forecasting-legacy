class Stats::TrendBuilder
  def pluck(&pluck_block)
    @pluck_block = pluck_block
    self
  end

  def map(&map_block)
    @map_block = map_block
    self
  end

  def analyze(series)
    series.map do |item|
      value = @pluck_block.call(item)
      @map_block.call(item, value, 0)
    end
  end
end