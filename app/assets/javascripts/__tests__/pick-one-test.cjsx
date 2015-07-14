jest
  .dontMock '../components/core-tools/pick-one'

jest
  .dontMock '../components/core-tools/generic'

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
      instruction: "Do you have a favorite ice cream flavour?",
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

    # mock of the props.onChange from subject-viewer
    clickRecord = jest.genMockFunction()
    # mockReturnThis(@props.annotation.value = "")


    PickOne = require '../components/core-tools/pick-one'
    GenericTask = require '../components/core-tools/generic'

    shallowRenderer = React.addons.TestUtils.createRenderer()
    shallowRenderer.render(<PickOne annotation={""} task={task_object} onChange={clickRecord} />)
    result = shallowRenderer.getRenderOutput()

    it 'should load the SingleChoiceTask/pickOne', ->
        expect(PickOne).toBeTruthy()

    # this seems like it could be improved. not sure that this is an effective use of shallowRender
    it "should render a function with the displayName GenericTask", ->
      expect(result.type.displayName).toBe("GenericTask")
      expect(result.type.defaultProps.question).toBe('')
      expect(result.type.defaultProps.answers).toBe('')
      expect(result.type.defaultProps.help).toBe('')

    it "should create 2 <label>s", ->
      DOM = renderIntoDocument(<PickOne annotation={""} task={task_object} onChange={clickRecord} />)
      labels = scryRenderedDOMComponentsWithTag(DOM, 'label')
      expect(labels.length).toEqual(2)

    it "upon initial render none of the labels' classes should be 'active' ",->
      DOM = renderIntoDocument(<PickOne annotation={""} task={task_object} onChange={clickRecord} />)
      labels = scryRenderedDOMComponentsWithTag(DOM, 'label')
      expect(labels[0].props.className).not.toContain("active")
      expect(labels[1].props.className).not.toContain("active")

    it "when a label is clicked the class should contain the word 'active' ", ->
      DOM = renderIntoDocument(<PickOne annotation={value: "yes"} task={task_object} onChange={clickRecord} />)
      labels = scryRenderedDOMComponentsWithTag(DOM, 'label')
      inputs = scryRenderedDOMComponentsWithTag(DOM, 'input')

      Simulate.change(inputs[0], target: {checked:true})
      expect(clickRecord).toBeCalled()
      expect(labels[0].props.className).toContain("active")






