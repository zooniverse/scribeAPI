String.prototype.capitalize = function() {
  return this.replace(/^./, match => match.toUpperCase());
};

String.prototype.truncate = function(max, add) {
  if (add == null) {
    add = "...";
  }
  if (this.length > max) {
    return this.substring(0, max) + add;
  } else {
    return this;
  }
};
