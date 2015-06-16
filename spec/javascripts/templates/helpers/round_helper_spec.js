describe('templates/helpers/round', function () {
  var template;

  beforeEach(function () {
    var source = "{{round x}}";
    this.template = Handlebars.compile(source);
  });

  it("rounds numbers to 1 significant figure", function () {
    var output = this.template({x: 123.45});
    expect(output).toBe('123.5');
  });
});