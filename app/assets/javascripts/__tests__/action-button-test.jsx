const React = require("react");
const ReactTestUtils = require("react-dom/test-utils");
const ActionButton = require("../components/action-button.jsx");

describe("ActionButton", function () {
  let actionButton;

  actionButton = ReactTestUtils.renderIntoDocument(<ActionButton />);

  it("should grab the action-button code", () =>
    expect(actionButton).toBeTruthy());
});
