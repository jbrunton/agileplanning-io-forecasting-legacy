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
  // TODO: extract these functions
  var bisectDate = d3.bisector(function(d) { return d.completed ? d.completed : d.date; }).left;

  function cycleTimeTip(d, active) {
    var context = { d: d, active: active };
    return HandlebarsTemplates['epic_tooltip'](context);
  }

  function wipTip(d, active) {
    var context = { d: d, active: active };
    return HandlebarsTemplates['wip_tooltip'](context);
  }

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


  // paths

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


  // points

  var cycleTimeCircle = chart.svg.selectAll("circle.cycle_time")
      .data(cycleTimeSeries)
      .enter().append("circle")
      .attr("cx", function(d) { return chart._xScale(d.completed); })
      .attr("cy", function(d) { return chart._yCycleTimeScale(d.cycleTime); })
      .attr("r", 3)
      .classed("cycle_time", true);

  var wipCircle = chart.svg.selectAll("circle.wip")
      .data(wipSeries)
      .enter().append("circle")
      .attr("cx", function(d) { return chart._xScale(d.date); })
      .attr("cy", function(d) { return chart._yWipScale(d.wip); })
      .attr("r", 1.5)
      .classed("wip", true);


  // areas

  var cycleTimeArea = d3.svg.area()
      .x(function(d) { return chart._xScale(d.completed); })
      .y0(function(d) { return chart._yCycleTimeScale(d.avg - d.sd); })
      .y1(function(d) { return chart._yCycleTimeScale(d.avg + d.sd); });

  chart.svg.append("path")
      .datum(cycleTimeSeries)
      .attr("class", "area")
      .attr("d", cycleTimeArea)
      .classed("cycle_time", true);

  var wipArea = d3.svg.area()
      .x(function(d) { return chart._xScale(d.date); })
      .y0(function(d) { return chart._yWipScale(d.avg - d.sd); })
      .y1(function(d) { return chart._yWipScale(d.avg + d.sd); });

  chart.svg.append("path")
      .datum(wipSeries)
      .attr("class", "area")
      .attr("d", wipArea)
      .classed("wip", true);


  // axes

  var xAxis = d3.svg.axis()
      .scale(chart._xScale)
      .ticks(5)
      .orient("bottom");

  chart.svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + chart.getClientHeight() + ")")
      .call(xAxis);

  var yCycleTimeAxis = d3.svg.axis()
      .scale(chart._yCycleTimeScale)
      .orient("left");

  chart.svg.append("g")
      .attr("class", "y axis")
      .call(yCycleTimeAxis);

  var yWipAxis = d3.svg.axis()
      .scale(chart._yWipScale)
      .tickFormat(d3.format("d"))
      .orient("right");

  chart.svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + chart.getClientWidth() + ",0)")
      .call(yWipAxis);


  // overlay

  $('.d3-tip').remove();

  var focusActive = false;

  var tip = d3.tip().attr('class', 'd3-tip')
      .direction(function(d) {
        var y = d.cycleTime ? chart._yCycleTimeScale(d.cycleTime) : chart._yWipScale(d.wip);
        return y > chart.getClientHeight() / 2 ? 'n' : 's';
      })
      .offset(function(d) {
        var y = d.cycleTime ? chart._yCycleTimeScale(d.cycleTime) : chart._yWipScale(d.wip);
        return y > chart.getClientHeight() / 2 ? [-10, 0] : [10, 0];
      })
      .html(function(d) {
        var html = "";
        if (d.cycleTime) {
          html += cycleTimeTip(d, focusActive);
        } else {
          html += wipTip(d, focusActive);
        }
        return html;
      });

  chart.svg.call(tip);

  var overlay = chart.svg.append('rect')
      .attr('class', 'overlay')
      .attr('width', chart.getClientWidth())
      .attr('height', chart.getClientHeight());

  var focus = chart.svg.append('g').style('display', 'none');
  focus.append('circle')
      .attr('id', 'focusCircle')
      .attr('r', 5);

  overlay.on('click', function() { focusActive = false; tip.hide(); focus.style('display', 'none'); })
      .on('mousemove', function() {
        function getMouseXY(self) {
          var mouse = d3.mouse(self);
          return { x: mouse[0], y: mouse[1] };
        }

        function getCycleTimeXY(index) {
          if (index < 0 || index >= cycleTimeSeries.length) {
            return { x: -999999, y: -999999, data: d };
          }
          var d = cycleTimeSeries[index];
          return { x: chart._xScale(d.completed), y: chart._yCycleTimeScale(d.cycleTime), data: d };
        }

        function getWipXY(index) {
          if (index < 0 || index >= wipSeries.length) {
            return { x: -999999, y: -999999, data: d };
          }
          var d = wipSeries[index];
          return { x: chart._xScale(d.date), y: chart._yWipScale(d.wip), data: d };
        }

        function distanceSq(p0, p1) {
          return Math.pow(p1.x - p0.x, 2) + Math.pow(p1.y - p0.y, 2);
        }

        function getClosestCycleTimeXY(p) {
          var mouseDate = chart._xScale.invert(mouse.x);
          var i = bisectDate(cycleTimeSeries, mouseDate); // returns the index to the current data item
          var p0 = getCycleTimeXY(i - 1);
          var p1 = getCycleTimeXY(i);

          p0.dist = distanceSq(p0, mouse);
          p1.dist = distanceSq(p1, mouse);

          // work out which date value is closest to the mouse
          return p0.dist > p1.dist ? p1 : p0;
        }

        function getClosestWipXY(p) {
          var mouseDate = chart._xScale.invert(mouse.x);
          var i = bisectDate(wipSeries, mouseDate); // returns the index to the current data item
          var p0 = getWipXY(i - 1);
          var p1 = getWipXY(i);

          p0.dist = distanceSq(p0, mouse);
          p1.dist = distanceSq(p1, mouse);

          // work out which date value is closest to the mouse
          return p0.dist > p1.dist ? p1 : p0;
        }

        var mouse = getMouseXY(this);
        var pCycleTime = getClosestCycleTimeXY(mouse);
        var pWip = getClosestWipXY(mouse);

        if (focusActive) {
          return;
        }

        if (pCycleTime.dist < pWip.dist && pCycleTime.dist < 2500) {
          focus.select('#focusCircle')
              .attr('cx', pCycleTime.x)
              .attr('cy', pCycleTime.y)
              .attr('class', 'cycle_time')
              .on('click', function() {
                focusActive = true;
                tip.show(pCycleTime.data, target);
              });
          var target = d3.selectAll("circle.cycle_time").filter(function(d) { return d == pCycleTime.data; })[0][0];
          tip.show(pCycleTime.data, target);
          tip.attr('class', 'd3-tip cycle_time');
          focus.style('display', null);
        } else {
          focus.select('#focusCircle')
              .attr('cx', pWip.x)
              .attr('cy', pWip.y)
              .attr('class', 'wip')
              .on('click', function() {
                focusActive = true;
                tip.show(pWip.data, target);
              });

          var target = d3.selectAll("circle.wip").filter(function(d) { return d == pWip.data; })[0][0];
          tip.show(pWip.data, target);
          tip.attr('class', 'd3-tip wip');
          focus.style('display', null);
        }
      });
};
