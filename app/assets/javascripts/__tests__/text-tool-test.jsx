
import React from "react";
import ReactTestUtils from "react-dom/test-utils";

describe("text-tool index", function () {
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
  };

  const TextTool = require("../components/transcribe/tools/text-tool/index");

  it("should load the TextTool module", () =>
    expect(TextTool).toBeTruthy());

  xit("should render with an empty text input field", () => {
    let DOM;
    return (DOM = renderIntoDocument(<TextTool />));
  });

  xit("should display the correct label", () => { });

  xit("a keypress should change input", () => { });

  xit("should done button should call a commit function", () => { });
});
