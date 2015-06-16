Handlebars.registerHelper('date', function(date) {
  var formatDate = d3.time.format("%a %-d %b");
  if (date) {
    return new Handlebars.SafeString(formatDate(date));
  }
});
