jest
  .dontMock '../components/core-tools/pick-one'

  describe 'SingleChoiceTask/pickOne', ->
    React = require 'react/addons'

    {
      renderIntoDocument, 
      scryRenderedComponentsWithType, 
      scryRenderedDOMComponentsWithClass, 
      findRenderedDOMComponentWithTag,
      Simulate
    } = React.addons.TestUtils
    
    task_object = {
      generates_subject_type: null, 
      instruction: "Do you have a favorite ice cream flavour",
      key: "pick_page_type",
      next_task: null,
      tool: "pickOne"
      tool_config: {
        yes: {
          label: "yes",
          next_task: null
          },
        no: {
          label: "no",
          next_task: null
        }
      }
    }

    clickRecord = clickRecord: (mark) ->
      console.log "handled that change"

    PickOne = require '../components/core-tools/pick-one'
    pickOne = renderIntoDocument(<PickOne annotation={""} task={task_object} onChange={clickRecord} />)
    # doesn't work as expected -- shallow render needed?
    input = findRenderedDOMComponentWithTag(renderedItem, 'input')
    console.log "INPUT", input
    label = scryRenderedDOMComponentsWithClass(pickOne, 'minor-button') 
    console.log "LABEL", label

    it 'should load the SingleChoiceTask/pickOne', ->
      expect(PickOne).toBeTruthy()

    # it 'should show active class if the a label has been clicked', ->



