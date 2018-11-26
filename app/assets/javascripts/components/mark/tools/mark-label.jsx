import React from "react";

/**
 * Shows a label within a marking box, if show_labels is set to true in
 * the project.json.
 */
export default function MarkLabel(props) {
  const { project } = window;
  if (project.show_labels) {
    const { x, y, label } = props;
    return <text x={x} y={y} fontSize="30" fill="#000" stroke="none" className="mark-label">{label}</text>
  } else {
    return null;
  }
}
