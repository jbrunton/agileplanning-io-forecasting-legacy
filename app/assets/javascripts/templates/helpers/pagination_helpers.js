Handlebars.registerHelper('paginationIndex', function(pageIndex) {
  return new Handlebars.SafeString(pageIndex + 1);
});

Handlebars.registerHelper('paginationClass', function(pageIndex, currentPageIndex) {
  return new Handlebars.SafeString(pageIndex === currentPageIndex ? 'current' : '');
});

Handlebars.registerHelper('paginationShow', function(pageIndex, currentPageIndex, pages) {
  var min = currentPageIndex - 3,
      max = currentPageIndex + 3;
  while (min < 0) {
    min += 1;
    max += 1;
  }
  while (max > pages.length && min > 0) {
    min -= 1;
    max -= 1;
  }
  return min <= pageIndex && pageIndex <= max;
});
