const path = require("path");

module.exports = {
  target: "node",
  entry: "./src/parser.js",
  mode: "production",
  output: {
    filename: "parser.js",
    path: path.resolve(__dirname, "dist"),
  },
};
