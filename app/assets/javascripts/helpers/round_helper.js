Handlebars.registerHelper('round', function(number) {
  if (number) {
    return new Handlebars.SafeString(number.toFixed(1));
  }
});
