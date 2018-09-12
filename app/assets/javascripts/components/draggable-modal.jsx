/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react";
import ReactDOM from "react-dom";
import Draggable from "../lib/draggable.jsx";
import DoneButton from "./buttons/done-button.jsx";
import createReactClass from "create-react-class";

export default createReactClass({
  displayName: "DraggableModal",

  getDefaultProps() {
    return {
      classes: "",
      doneButtonLabel: "Done"
    };
  },

  componentDidMount() {
    // Prevent dragging from (presumably) accidentally selecting modal text on-drag
    return $(ReactDOM.findDOMNode(this)).disableSelection();
  },

  closeModal() {
    if (this.props.onClose) {
      this.props.onClose();
    }
    return this.setState({ closed: true });
  },

  render() {
    let { onDone } = this.props;
    if (onDone == null) {
      onDone = () => {
        return this.setState({ closed: true });
      };
    }

    let { onClickStep } = this.props;
    if (onClickStep == null) {
      onClickStep = function() {};
    }

    // Position roughly in center of screen unless explicit x,y given:
    const width = this.props.width != null ? this.props.width : 400;
    let x =
      this.props.x != null ? this.props.x : ($(window).width() - width) / 2;
    let header_h = 80;
    if ($(".main-nav").length > 0) {
      header_h = $(".main-nav")
        .first()
        .height();
    }
    let y =
      this.props.y != null
        ? this.props.y
        : header_h + 30 + $(window).scrollTop();
    y = Math.max(y, 50);
    x = Math.max(x, 100);
    if (x > $(window).width() - width) {
      x = $(window).width() - width;
    }

    return (
      <Draggable x={x} y={y}>
        <div className={`draggable-modal ${this.props.classes}`}>
          {this.props.closeButton != null ? (
            <a className="modal-close-button" onClick={this.closeModal} />
          ) : (
            undefined
          )}
          {this.props.header != null ? (
            <div className="modal-header">{this.props.header}</div>
          ) : (
            undefined
          )}
          <div className="modal-body">{this.props.children}</div>
          {this.props.progressSteps && this.props.progressSteps.length > 1 ? (
            <div className="simple-progress-bar">
              {Array.from(this.props.progressSteps).map(
                (step, index) =>
                  index === this.props.currentStepIndex ? (
                    <span
                      key={index}
                      className="tutorial-progress-ind active"
                    />
                  ) : index <= this.props.currentStepIndex ? (
                    <span
                      key={index}
                      className="tutorial-progress-ind completed"
                      onClick={onClickStep.bind(null, index)}
                    />
                  ) : (
                    <span
                      key={index}
                      className="tutorial-progress-ind"
                      onClick={onClickStep.bind(null, index)}
                    />
                  )
              )}
            </div>
          ) : (
            undefined
          )}
          <div className="modal-buttons">
            {(() => {
              if (this.props.buttons != null) {
                return this.props.buttons;
              } else if (onDone != null) {
                return (
                  <DoneButton
                    label={this.props.doneButtonLabel}
                    onClick={onDone}
                  />
                );
              }
            })()}
          </div>
        </div>
      </Draggable>
    );
  }
});
