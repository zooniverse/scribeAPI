import GenericTask from "../components/core-tools/generic.jsx";
describe("GenericTask", function () {
  it("should grab the GenericTask code", () =>
    expect(GenericTask).toBeTruthy());
});
// this isn't working because the props.answers is an array of react elements from the parent core-tool
// genericTask = renderIntoDocument(<GenericTask questions={"What color is the moon?"} answers={["yellow", "blue"]} />)
