jest
  .dontMock '../components/core-tools/pick-one'

  describe 'SingleChoiceTask/pickOne', ->
    React = require 'react/addons'

    {
      renderIntoDocument, 
      scryRenderedComponentsWithType, 
      scryRenderedDOMComponentsWithClass, 
      scryRenderedDOMComponentsWithTag,
      createRenderer,
      Simulate
    } = React.addons.TestUtils
    
    task_object = {
      generates_subject_type: null, 
      instruction: "Do you have a favorite ice cream flavour",
      key: "pick_page_type",
      next_task: null,
      tool: "pickOne"
      tool_config: {
        options: {
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
    }

    clickRecord = clickRecord: (mark) ->
      console.log "handled that change"

    PickOne = require '../components/core-tools/pick-one'
    GenericTask = require '../components/core-tools/generic'
    
    # pickOne = renderIntoDocument(<PickOne annotation={""} task={task_object} onChange={clickRecord} />)
    # console.log "pickOne.props.children", pickOne.props.children
    
    shallowRenderer = React.addons.TestUtils.createRenderer()
    shallowRenderer.render(<PickOne annotation={""} task={task_object} onChange={clickRecord} />)
    result = shallowRenderer.getRenderOutput()

    # console.log "RESUlT.props.children", result.props.children

    it "shallow render produces to 2 <label>s", ->
      labels = scryRenderedDOMComponentsWithTag(result.props, 'label')
      console.log "labels", labels
  



    

    # labels = scryRenderedDOMComponentsWithTag(pickOne, 'label')
    # console.log "LABELS", labels

    # label = scryRenderedDOMComponentsWithClass(pickOne, 'minor-button') 
    # console.log "LABEL", label

    # it 'should load the SingleChoiceTask/pickOne', ->
    #   expect(PickOne).toBeTruthy()

    # it 'should show active class if the a label has been clicked', ->



