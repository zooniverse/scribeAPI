jest.dontMock("../components/action-button");

describe("ActionButton", function () {
  let actionButton;
  const React = require("react/addons");

  const ActionButton = require("../components/action-button");

  it("should grab the action-button code", () =>
    expect(ActionButton).toBeTruthy());

  actionButton = React.addons.TestUtils.renderIntoDocument(<ActionButton />);
});
