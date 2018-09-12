import React from "react";
import ReactTestUtils from "react-dom/test-utils";
import ActionButton from "../components/action-button.jsx";

describe("ActionButton", function () {
  let actionButton;

  actionButton = ReactTestUtils.renderIntoDocument(<ActionButton />);

  it("should grab the action-button code", () =>
    expect(actionButton).toBeTruthy());
});
