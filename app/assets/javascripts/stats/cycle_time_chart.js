function CycleTimeChart(opts) {
  var keys = ['container', 'aspectRatio', 'margin'];
  for (var k in keys) {
    var key = keys[k];
    this[key] = opts[key];
  }
}

CycleTimeChart.prototype.getWidth = function() {
  return $(this.container).width();
};

CycleTimeChart.prototype.getHeight = function() {
  return $(this.container).height();
};

CycleTimeChart.prototype.getClientWidth = function() {
  return this.getWidth() - (this.margin.left + this.margin.right);
};

CycleTimeChart.prototype.getClientHeight = function() {
  return this.getHeight() - (this.margin.top + this.margin.bottom);
};

CycleTimeChart.prototype.bind = function() {
  $(this.container).height($(this.container).width() / this.aspectRatio);
  $(this.container).empty();
  this.svg = d3.select(this.container)
      .attr("width", this.getWidth())
      .attr("height", this.getHeight())
      .append("g")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");
};

CycleTimeChart.prototype.setSeries = function(cycleTimeSeries, wipSeries) {
  this.cycleTimeSeries = cycleTimeSeries;
  this.wipSeries = wipSeries;

  var allDates = cycleTimeSeries.map(function(d) { return d.completed; })
      .concat(wipSeries.map(function(d) { return d.date; }));

  this._xScale = d3.time.scale()
      .domain([d3.min(allDates), d3.max(allDates)])
      .range([0, this.getClientWidth()], .1);

  this._yCycleTimeScale = d3.scale.linear()
      .domain([0, d3.max(cycleTimeSeries, function(d) { return d.cycleTime; })])
      .range([this.getClientHeight(), 0]);

  this._yWipScale = d3.scale.linear()
      .domain([0, d3.max(wipSeries, function(d) { return d.wip; })])
      .range([this.getClientHeight(), 0]);

  var chart = this;
  var cycleTimeLine = d3.svg.line()
      .x(function(d) { return chart._xScale(d.completed); })
      .y(function(d) { return chart._yCycleTimeScale(d.avg); });

  this.svg.append("path")
      .datum(this.cycleTimeSeries)
      .attr("class", "line")
      .attr("d", cycleTimeLine)
      .classed("cycle_time", true)
      .classed("mean", true);

  var wipLine = d3.svg.line()
      .interpolate("monotone")
      .x(function(d) { return chart._xScale(d.date); })
      .y(function(d) { return chart._yWipScale(d.avg); });

  this.svg.append("path")
      .datum(this.wipSeries)
      .attr("class", "line")
      .attr("d", wipLine)
      .classed("wip", true)
      .classed("mean", true);
};