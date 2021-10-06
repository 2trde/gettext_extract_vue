const parser = require("@babel/parser");
const { default: traverse } = require("@babel/traverse");
const fs = require("fs");

const file = process.argv[2];
const code = fs.readFileSync(file);

const result = parser.parse(code.toString("utf-8"), {
  sourceType: "module",
  plugins: ["jsx"],
});

const gettextValues = [];

traverse(result, {
  JSXElement(path) {
    const { node } = path;
    if (node.openingElement?.name?.name === "Translate") {
      if (node.children.length !== 1) {
        console.error(
          `Expected only one child of <Translate>, received ${node.children.length}`
        );
        process.exit(1);
      }
      const child = node.children[0];
      if (child.type === "JSXText") {
        gettextValues.push(child.value);
      }
    }
  },
  CallExpression(path) {
    const { node } = path;
    if (["gettext", "t"].includes(node.callee.name)) {
      gettextValues.push(
        ...node.arguments
          .filter(({ value }) => typeof value === "string")
          .map(({ value }) => value)
      );
    }
  },
});

console.log(JSON.stringify(gettextValues));
