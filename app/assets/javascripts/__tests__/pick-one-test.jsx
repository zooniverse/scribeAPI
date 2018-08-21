import ReactTestUtils from "react-dom/test-utils";
global.marked = (text) => text;

describe("SingleChoiceTask/pickOne", function () {
  const {
    renderIntoDocument,
    scryRenderedComponentsWithType,
    scryRenderedDOMComponentsWithClass,
    scryRenderedDOMComponentsWithTag,
    createRenderer,
    Simulate
  } = ReactTestUtils;

  const task_object = {
    generates_subject_type: null,
    instruction: "Do you have a favorite ice cream flavour?",
    key: "pick_page_type",
    next_task: null,
    tool: "pickOne",
    tool_config: {
      options: [{
        value: "yes",
        label: "Yes",
        next_task: null
      }, {
        value: "no",
        label: "No",
        next_task: null
      }]
    }
  };

  // mock of the props.onChange from subject-viewer
  const clickRecord = jest.genMockFunction();

  const PickOne = require("../components/core-tools/pick-one");
  const GenericTask = require("../components/core-tools/generic");

  const ShallowRenderer = require('react-test-renderer/shallow');
  const shallowRenderer = new ShallowRenderer();
  shallowRenderer.render(
    <PickOne annotation="" task={task_object} onChange={clickRecord} />
  );
  const result = shallowRenderer.getRenderOutput();

  it("should load the SingleChoiceTask/pickOne", () =>
    expect(PickOne).toBeTruthy());

  // this seems like it could be improved. not sure that this is an effective use of shallowRender
  it("should render a function with the displayName GenericTask", function () {
    expect(result.type.displayName).toBe("GenericTask");
    expect(result.type.defaultProps.question).toBe("");
    expect(result.type.defaultProps.answers).toBe("");
    expect(result.type.defaultProps.help).toBe("");
  });

  it("should create 2 <label>s", () => {
    const DOM = renderIntoDocument(
      <PickOne annotation="" task={task_object} onChange={clickRecord} />
    );
    const labels = scryRenderedDOMComponentsWithTag(DOM, "label");
    expect(labels.length).toEqual(2);
  });

  it("upon initial render none of the labels' classes should be 'active' ", () => {
    const DOM = renderIntoDocument(
      <PickOne annotation="" task={task_object} onChange={clickRecord} />
    );
    const labels = scryRenderedDOMComponentsWithTag(DOM, "label");
    expect(labels[0].props.className).not.toContain("active");
    expect(labels[1].props.className).not.toContain("active");
  });

  it("when a label is clicked the class @handleChange should be called & label should contain the word 'active' ", () => {
    const DOM = renderIntoDocument(
      <PickOne
        annotation={{ value: "yes" }}
        task={task_object}
        onChange={clickRecord}
      />
    );
    const labels = scryRenderedDOMComponentsWithTag(DOM, "label");
    const inputs = scryRenderedDOMComponentsWithTag(DOM, "input");

    Simulate.change(inputs[0], { target: { checked: true } });
    expect(clickRecord).toBeCalled(); //the mock func stands in for the subject-viewer's @handleChange()
    expect(labels[0].props.className).toContain("active");
  });
});
