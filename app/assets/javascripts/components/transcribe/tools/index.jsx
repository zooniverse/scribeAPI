module.exports = {
  // transcribeTool:   require './transcribe-row-tool'
  compositeTool: require("./composite-tool/index.jsx"),
  singleTool: require("./single-tool/index.jsx"),

  textTool: require("./text-tool/index.jsx"), // this will soon be subsumed by single-tool
  dateTool: require("./date-tool/index.jsx"),
  numberTool: require("./number-tool/index.jsx"),
  textAreaTool: require("./text-area-tool/index.jsx")
};
