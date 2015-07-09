var coffee = require('coffee-script');
var transform = require('coffee-react-transform');

module.exports = {
    process: function(src, path) {
        if (path.match(/\.cjsx/) || (coffee.helpers.isCoffee(path))) {
            return coffee.compile(transform(src), {'bare': true});
        }
        return src;
    }
};