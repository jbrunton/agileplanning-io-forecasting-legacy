describe('templates/helpers/date', function () {
  var template;

  beforeEach(function () {
    var source = "{{date x}}";
    this.template = Handlebars.compile(source);
  });

  it("formats the date", function () {
    var output = this.template({x: new Date(2001, 0, 1)});
    expect(output).toBe('Mon 1 Jan');
  });
});