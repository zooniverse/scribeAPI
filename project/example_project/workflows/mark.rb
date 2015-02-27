Mark_workflow = {
  label: "mark",
  tasks: {
    first_task: "pick_page_type",
    tasks: {

      pick_page_type: {
        next_task: "attestation_task"
        tools: pick_one,
        options: {

          history_sheet: {
            next_task: "history_sheet_task"
          },

          casualty_form: {
            next_task: "casualty_form_task"
          },

          attestation: {
            next_task: "attestation_task"
          }

        }, #end of options
      }, #end of task one

      attestation_task: {
      next_task: null
        tool: pick_one_mark_one,
        options: {

          header: {
            tool: rectangle_tool,
            directions: "Draw a rectangle around the 'Header' region."
          },

          oath: {
            tool: rectangle_tool,
            directions: "Draw a rectangle around the 'Oath' region."
          },

          attesting_officer: {
            tool: rectangle_tool,
            directions: "Draw a rectangle around the 'Attesting Officer' region."
          },

          question: {
            tool: rectangle_tool,
            directions: "Draw a rectangle around the 'Question' region."
          } # end of options

        } #end of options
      }, #end of task two

      # history_sheet_task: { },
      # casualty_form_task: { }

    }
  }

}
