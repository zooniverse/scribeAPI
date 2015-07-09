jest.dontMock '../components/action-button'

describe 'ActionButton', ->
  React = require 'react/addons'
  {findRenderedDOMComponentWithTag, scryRenderedComponentsWithType, findRenderedComponentWithType, findRenderedDOMComponentWithClass, renderIntoDocument, Simulate} = React.addons.TestUtils

  ActionButton = renderIntoDocument(<ActionButton/>)

