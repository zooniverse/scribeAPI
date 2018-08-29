const React = require("react");
const ReactDOM = require("react-dom");
const DraggableModal = require("./draggable-modal.jsx");
const createReactClass = require("create-react-class");

module.exports = createReactClass({
  displayName: "HelpModal",

  componentDidMount() {
    const el = $(ReactDOM.findDOMNode(this)).find("#accordion-help-modal");
    el.accordion({
      collapsible: true,
      active: false,
      heightStyle: "content"
    });
  },

  render() {
    if (this.props.help == null) {
      return null;
    }
    return (
      <DraggableModal
        header={this.props.help.title != null ? this.props.help.title : "Help"}
        onDone={this.props.onDone}
        width={600}
        classes="help-modal"
      >
        <div
          dangerouslySetInnerHTML={{ __html: marked(this.props.help.body) }}
        />
      </DraggableModal>
    );
  }
});
