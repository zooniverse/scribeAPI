class Project {
  constructor(obj) {
    for (let k in obj) {
      const v = obj[k];
      this[k] = v;
    }
  }

  term(t) {
    return this.terms_map[t] != null ? this.terms_map[t] : t;
  }
}

module.exports = Project;
