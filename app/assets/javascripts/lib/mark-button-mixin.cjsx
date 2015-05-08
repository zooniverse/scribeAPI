MarkButton = require 'components/mark-button'

module.exports =

  getInitialState: ->
    markStatus: 'waiting-for-mark'
    locked: ''

  renderMarkButton: ->
    <MarkButton
      tool={this}
      onDrag={@onClickMarkButton}
      position={@getMarkButtonPosition()}
      markStatus={@state.markStatus}
      locked={@state.locked}
    />

  onClickMarkButton: ->
    # @props.submitMark(@props.mark) # disable for now -STI

    markStatus = @state.markStatus
    switch markStatus
      when 'waiting-for-mark'
        @setState
          markStatus: 'mark-finished'
          locked: true
        # @props.submitMark(@props.key)
        console.log 'Mark submitted. Click TRANSCRIBE to begin transcribing.'
      when 'mark-finished'
        @setState
          markStatus: 'transcribe'
          locked: true
        # @props.onClickTranscribe(@state.mark.key)
        # @transcribeMark(mark)

        console.log 'Going into TRANSCRIBE mode. Stand by.'
      when 'transcribe'
        @setState
          markStatus: 'transcribe-finished'
          locked: true
        # @submitTranscription()
        console.log 'Transcription submitted.'
      when 'transcribe-finished'
        @setState locked: true
        console.log 'All done. Nothing left to do here.'
      else
        @setState locked: true
        console.log 'WARNING: Unknown state in handleToolProgress()'
