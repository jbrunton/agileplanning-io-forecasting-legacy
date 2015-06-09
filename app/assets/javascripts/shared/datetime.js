window.datetime = {
  parseDate: d3.time.format("%Y-%m-%d").parse,
  parseTime: d3.time.format("%Y-%m-%dT%H:%M:%S.%LZ").parse,
  formatDate: d3.time.format("%a %-d %b")
};
