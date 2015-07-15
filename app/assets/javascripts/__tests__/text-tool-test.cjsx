jest
  .dontMock "../components/transcribe/tools/text-tool/index"

  TextTool = require "../components/transcribe/tools/text-tool/index"

  describe 'text-tool index', ->
    React = require 'react/addons'

    it "should load the TextTool module", ->
      expect(TextTool).toBeTruthy()

    