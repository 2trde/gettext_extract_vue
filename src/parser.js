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

const translateFuncs = ["gettext", "t"];
const commentPrefix = "@translations ";
const commentSeperator = "|";

traverse(result, {
  JSXEmptyExpression({ node }) {
    const comments = node?.innerComments
      ?.filter(({ type }) => type === "CommentBlock")
      ?.map(({ value }) => value.trim())
      ?.flatMap((value) =>
        value.startsWith(commentPrefix)
          ? value.slice(commentPrefix.length).split(commentSeperator)
          : []
      )
      ?.map((key) => key.trim());

    if (comments && comments.length > 0) {
      gettextValues.push(...comments);
    }
  },
  JSXElement({ node }) {
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
  CallExpression({ node }) {
    const isTranslateFunc = translateFuncs.includes(node.callee.name);
    const isTranslateMemberExpr =
      node.callee.type === "MemberExpression" &&
      translateFuncs.includes(node.callee.property.name);

    if (isTranslateFunc || isTranslateMemberExpr) {
      gettextValues.push(
        ...node.arguments
          .filter(({ value }) => typeof value === "string")
          .map(({ value }) => value)
      );
    }
  },
});

console.log(JSON.stringify(gettextValues));
