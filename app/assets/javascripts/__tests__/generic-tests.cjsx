jest
  .dontMock '../components/core-tools/generic'

  describe "GenericTask", ->
    React = require 'react/addons'
    {renderIntoDocument, Simulate} = React.addons.TestUtils
    
    GenericTask = require '../components/core-tools/generic'
    
    it 'should grab the GenericTask code', ->
      expect(GenericTask).toBeTruthy()
    # this isn't working becuase the props.answers is an array of react elements from the parent core-tool
    # genericTask = renderIntoDocument(<GenericTask questions={"What color is the moon?"} answers={["yellow", "blue"]} />)