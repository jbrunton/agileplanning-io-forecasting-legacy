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

  def self.sample_size(series_size)
    sample_size = (series_size * 0.2).to_i
    sample_size = sample_size + 1 if sample_size.even?
    [sample_size, 5].max
  end

  def self.pick_sample(series, index)
    sample_size = self.sample_size(series.length)
    start_index = [0, index - sample_size / 2 - 1].max
    end_index = start_index + sample_size

    while end_index > series.length
      start_index = start_index - 1 if start_index > 0
      end_index = end_index - 1
    end

    series[start_index..end_index - 1]
  end
end