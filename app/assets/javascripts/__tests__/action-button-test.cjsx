jest
  .dontMock '../components/action-button'
  
  describe 'ActionButton', ->
    React = require 'react/addons'
    {renderIntoDocument, Simulate} = React.addons.TestUtils
    {ActionButton} = require '../components/action-button'
    it 'should grab the action-button code', ->
      expect(ActionButton).toBeTruthy()

    # actionButton = renderIntoDocument(<ActionButton/>)
    
