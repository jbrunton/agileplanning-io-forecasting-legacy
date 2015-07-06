describe('templates/helpers/paginate', function () {
  beforeEach(function () {
    var source = "{{paginate pages currentPageIndex}}";
    this.template = Handlebars.compile(source);
  });

  describe('when given an empty list', function() {
    it('renders nothing', function () {
      var output = this.template({ pages: [] });
      expect(output).toBe('');
    });
  });

  describe('when given a list with one page', function() {
    beforeEach(function() {
      this.output = this.template({ pages: [1] });
    });

    it('renders a list', function() {
      expect($(this.output)).toContainElement('ul.pagination');
    });

    it('centers the list', function() {
      expect($(this.output)).toEqual('div.pagination-centered');
    });

    it('renders the link to the page', function() {
      expect($(this.output).find('ul.pagination')).toContainElement('li a[data-page-index=0]');
    });
  });

  describe('when given a list of pages', function() {
    it('renders links to each page', function() {
      var output = this.template({ pages: [1, 2] });
      expect(paginationLinks(output)).toEqual([
        { pageIndex: 0, text: "1" },
        { pageIndex: 1, text: "2" }
      ]);
    });

    it('selects the current page', function() {
      var output = this.template({ pages: [1, 2], currentPageIndex: 1 });
      expect(paginationLinks(output)).toEqual([
        { pageIndex: 0, text: "1" },
        { pageIndex: 1, text: "2", current: true }
      ]);
    });
  });

  describe('when given a long list of pages', function() {
    it('renders the surrounding 5 pages', function() {
      var output = this.template({ pages: [1, 2, 3, 4, 5, 6, 7], currentPageIndex: 3 });
      expect(paginationLinks(output)).toEqual([
        { arrow: true, direction: 'previous', text: '«' },
        { pageIndex: 1, text: "2" },
        { pageIndex: 2, text: "3" },
        { pageIndex: 3, text: "4", current: true },
        { pageIndex: 4, text: "5" },
        { pageIndex: 5, text: "6" },
        { arrow: true, direction: 'next', text: '»' }
      ]);
    });

    it('renders the first 5 pages when at the start of the range', function() {
      var output = this.template({ pages: [1, 2, 3, 4, 5, 6, 7], currentPageIndex: 1 });
      expect(paginationLinks(output)).toEqual([
        { pageIndex: 0, text: "1" },
        { pageIndex: 1, text: "2", current: true },
        { pageIndex: 2, text: "3" },
        { pageIndex: 3, text: "4" },
        { pageIndex: 4, text: "5" },
        { arrow: true, direction: 'next', text: '»' }
      ]);
    });

    it('renders the last 5 pages when at the end of the range', function() {
      var output = this.template({ pages: [1, 2, 3, 4, 5, 6, 7], currentPageIndex: 5 });
      expect(paginationLinks(output)).toEqual([
        { arrow: true, direction: 'previous', text: '«' },
        { pageIndex: 2, text: "3" },
        { pageIndex: 3, text: "4" },
        { pageIndex: 4, text: "5" },
        { pageIndex: 5, text: "6", current: true },
        { pageIndex: 6, text: "7" },
      ]);
    });
  });

  function paginationLinks(output) {
    function pickPageData(pageLink) {
      var data = {
          text: $(pageLink).text()
      };

      var pageIndex = $(pageLink).data('pageIndex');
      if (pageIndex != undefined) {
        data.pageIndex = pageIndex;
      }

      var listItem = $(pageLink).closest('li');
      if (listItem.hasClass('current')) {
        data.current = true;
      }
      if (listItem.hasClass('arrow')) {
        data.arrow = true;
        data.direction = $(pageLink).data('direction');
      }

      return data;
    }
    return $(output).find('ul.pagination li a').toArray().map(pickPageData);
  }
});