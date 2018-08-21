import React from "react";
import ReactTestUtils from "react-dom/test-utils";

describe("ActionButton", function () {
  let actionButton;

  const ActionButton = require("../components/action-button");

  it("should grab the action-button code", () =>
    expect(ActionButton).toBeTruthy());

  actionButton = ReactTestUtils.renderIntoDocument(<ActionButton />);
});
