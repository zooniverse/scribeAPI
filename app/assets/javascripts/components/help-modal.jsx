const React = require("react");
const DraggableModal = require("./draggable-modal");

module.exports = require('create-react-class')({
  displayName: "HelpModal",

  componentDidMount() {
    const el = $(React.findDOMNode(this)).find("#accordion-help-modal");
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
