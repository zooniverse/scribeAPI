jest
  .dontMock "../components/transcribe/tools/text-tool/index"

  TextTool = require "../components/transcribe/tools/text-tool/index"

  it "should load the TextTool module", ->
    expect(TextTool).toBeTruthy()