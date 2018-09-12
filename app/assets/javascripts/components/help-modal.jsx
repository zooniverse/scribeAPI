import React from "react";
import ReactDOM from "react-dom";
import marked from '../lib/marked.min.js';
import DraggableModal from "./draggable-modal.jsx";
import createReactClass from "create-react-class";

export default createReactClass({
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
