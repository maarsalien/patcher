const fs = require("fs");
const path = require("path");
const { minify } = require("luamin");
const { bundle } = require("luabundle");

const entryPoint = path.join(__dirname, "src", "index.lua");
const output = path.join(__dirname, "dist", "Patcher.lua");

const bundleOptions = {
  paths: [`src${path.sep}?.lua`],
};

if (!fs.existsSync(path.dirname(output))) fs.mkdirSync(path.dirname(output));

fs.writeFile(output, minify(bundle(entryPoint, bundleOptions)), (err) => {
  if (err) throw err;
  console.log("Build complete!");
  console.log(`Output: ${output}`);
});
