Handlebars.registerHelper('paginationIndex', function(pageIndex) {
  return new Handlebars.SafeString(pageIndex + 1);
});

Handlebars.registerHelper('paginationClass', function(pageIndex, currentPageIndex) {
  return new Handlebars.SafeString(pageIndex === currentPageIndex ? 'current' : '');
});
