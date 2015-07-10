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
      instruction: "How are you today?",
      key: "pick_page_type",
      next_task: null,
      tool: "pickOne"
      tool_config: {
        good: {
          label: "Good, thanks!",
          next_task: null
          },
        alright: {
          label: "I'm doing ok, thanks.",
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



