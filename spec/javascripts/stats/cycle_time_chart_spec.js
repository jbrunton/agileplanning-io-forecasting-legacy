describe('CycleTimeChart', function () {
  var container, chart, margin;

  beforeEach(function() {
    container = sandbox({id: 'container'});
    jasmine.getFixtures().set(container);

    margin = { top: 10, right: 40, bottom: 30, left: 40 };
    chart = new CycleTimeChart({
      container: '#container',
      aspectRatio: 2.0,
      margin: margin
    });
  });

  describe('constructor', function() {
    it('initializes the instance', function() {
      expect(chart.container).toEqual('#container');
      expect(chart.aspectRatio).toEqual(2.0);
      expect(chart.margin).toEqual({ top: 10, right: 40, bottom: 30, left: 40 });
    });
  });

  describe('#getWidth', function() {
    it('returns the width of the container', function() {
      container.width(200);
      expect(chart.getWidth()).toBe(200);
    });
  });

  describe('#getHeight', function() {
    it('returns the width of the container', function() {
      container.height(100);
      expect(chart.getHeight()).toBe(100);
    });
  });

  describe('#getClientWidth', function() {
    it('returns the width of the container, less margins', function() {
      container.width(200);
      expect(chart.getClientWidth()).toBe(200 - (margin.left + margin.right));
    });
  });

  describe('#getClientHeight', function() {
    it('returns the width of the container, less margins', function() {
      container.height(100);
      expect(chart.getClientHeight()).toBe(100 - (margin.top + margin.bottom));
    });
  });

  describe('#bind', function() {
    it('sizes the container', function() {
      container.width(200);

      chart.bind();

      expect(chart.getWidth()).toBe(200);
      expect(chart.getHeight()).toBe(100);
      expect(chart.getClientWidth()).toBe(120);
      expect(chart.getClientHeight()).toBe(60);
    });

    it('clears the container', function() {
      container.html('<span>whatevs</span>');
      chart.bind();
      expect(container).not.toContainText('whatevs');
    });
  });

  describe('#setSeries', function() {
    beforeEach(function() {
      chart.bind();
      expect(chart.getClientWidth()).toBeGreaterThan(0);
    });

    it('updates the series', function() {
      var wipSeries = [{}],
          cycleTimeSeries = [{}];

      chart.setSeries(cycleTimeSeries, wipSeries);

      expect(chart.cycleTimeSeries).toBe(cycleTimeSeries);
      expect(chart.wipSeries).toBe(wipSeries);
    });

    it('sets _xScale', function() {
      var firstDate = datetime.parseDate('2001-01-01'),
          anotherDate = datetime.parseDate('2001-02-01'),
          lastDate = datetime.parseDate('2001-03-01');
      var cycleTimeSeries = [{ completed: firstDate }, { completed: anotherDate }],
          wipSeries = [{ date: anotherDate }, { date: lastDate }];

      chart.setSeries(cycleTimeSeries, wipSeries);

      expect(chart._xScale(firstDate)).toBe(0);
      expect(chart._xScale(lastDate)).toBe(chart.getClientWidth());
    });
  });
});