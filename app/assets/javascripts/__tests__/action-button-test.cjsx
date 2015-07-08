jest.dontMock '../components/action-button-test'

describe 'ActionButton', ->
  React = require 'react/addons'
  {findRenderedDOMComponentWithTag, scryRenderedComponentsWithType, findRenderedComponentWithType, findRenderedDOMComponentWithClass, renderIntoDocument, Simulate} = React.addons.TestUtils

  ActionButton = renderIntoDocument(<ActionButton/>)

  describe 'onClick' ->
    Simulate.onClick
      # with a generic button like this not sure what to test at this point
      # however starting to see how this works.