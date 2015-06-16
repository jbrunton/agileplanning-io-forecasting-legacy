describe('datetime', function() {
  describe('parseDate', function() {
    it('parses a YYYY-MM-DD string', function() {
      var date = datetime.parseDate('2001-01-01');

      expect(date.getFullYear()).toBe(2001);
      expect(date.getMonth()).toBe(0);
      expect(date.getDate()).toBe(1);
    });
  });

  describe('parseTime', function() {
    it('parses an ISO 8601 UCT datetime string', function () {
      var date = datetime.parseTime('2001-01-01T14:30:20.123Z');

      expect(date.getFullYear()).toBe(2001);
      expect(date.getMonth()).toBe(0);
      expect(date.getDate()).toBe(1);
      expect(date.getHours()).toBe(14);
      expect(date.getMinutes()).toBe(30);
      expect(date.getSeconds()).toBe(20);
      expect(date.getMilliseconds()).toBe(123);
    });
  });

  describe('formatDate', function() {
    it('formats the date', function() {
      var date = new Date(2001, 0, 1);
      expect(datetime.formatDate(date)).toBe('Mon 1 Jan');
    });
  });
});