Handlebars.registerHelper('paginate', function(pages, currentPageIndex) {
  var content = '';

  if (pages.length > 0) {
    content += '<div class="pagination-centered"><ul class="pagination">';

    var minPageIndex = Math.max((currentPageIndex || 0) - 2, 0),
        maxPageIndex = minPageIndex + 4;

    while (minPageIndex > 0 && maxPageIndex >= pages.length) {
      minPageIndex -= 1;
      maxPageIndex -= 1;
    }

    if (minPageIndex > 0) {
      content += '<li class="arrow"><a href="#" data-direction="previous">&laquo;</a></li>';
    }

    pages.forEach(function(_, index) {
      if (index < minPageIndex || index > maxPageIndex) {
        return;
      }
      content += '<li class="';
      if (index === currentPageIndex) {
        content += 'current';
      }
      content += '">';
      content += '<a href="#" data-page-index="' + index + '"';
      content += '>' + (index + 1) + '</a>';
      content += '</li>';
    });

    if (maxPageIndex < pages.length - 1) {
      content += '<li class="arrow"><a href="#" data-direction="next">&raquo;</a></li>';
    }

    content += '</ul></div>';
  }

  return new Handlebars.SafeString(content);
});
