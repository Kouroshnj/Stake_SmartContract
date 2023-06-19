const path = require('path');

const routhPath = path.dirname(process.mainModule.filename)
console.log("this route path is:", routhPath);

module.exports = routhPath
