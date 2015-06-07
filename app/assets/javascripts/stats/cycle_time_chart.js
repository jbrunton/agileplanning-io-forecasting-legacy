function CycleTimeChart(opts) {
  var keys = ['container', 'aspectRatio', 'margin'];
  for (var k in keys) {
    var key = keys[k];
    this[key] = opts[key];
  }
}

CycleTimeChart.prototype.getWidth = function() {
  return $(this.container).width();
}

CycleTimeChart.prototype.getHeight = function() {
  return $(this.container).height();
}

CycleTimeChart.prototype.getClientWidth = function() {
  return this.getWidth() - (this.margin.left + this.margin.right);
}

CycleTimeChart.prototype.getClientHeight = function() {
  return this.getHeight() - (this.margin.top + this.margin.bottom);
}

CycleTimeChart.prototype.bind = function() {
  $(this.container).height($(this.container).width() / this.aspectRatio);
  this.svg = d3.select(this.container)
      .attr("width", this.getWidth())
      .attr("height", this.getHeight())
      .append("g")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");
}

