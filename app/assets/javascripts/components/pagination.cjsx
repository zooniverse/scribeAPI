React                     = require 'react'

module.exports = React.createClass
  displayName: 'Pagination'

  getDefaultProps: ->
    max_links: 12

  pageUrl: (page) ->
    base = location.href.replace /(&|\?)page=[^&]+/, ''
    "#{base}#{if base.indexOf("?") >= 0 then '&' else '?'}page=#{page}"
    
  render: ->
    # Build array of page numbers to show..
    
    pages = []
    if @props.total_pages <= @props.max_links
      # If fewer pages than max, show them all:
      pages = [1..@props.total_pages]

    else
      # Too many to show, so truncate..
      # Assuming we want three groups of truncated links (first few, last few,
      # and a middle group centered around current page)..
      chunk_size = @props.max_links / 3 - 1
      for p in [1..@props.total_pages]
        # Add first few pages:
        pages.push p if p <= chunk_size
        # Add a middle group of pages around the current page:
        pages.push p if Math.abs(@props.current_page - p) <= chunk_size/2 && pages.indexOf(p)<0
        # Bookend with last few pages:
        pages.push p if p > @props.total_pages - chunk_size && pages.indexOf(p)<0

    page_links = []

    # Add leading < link
    page_links.push({label: "&lt;", page: @props.prev_page, title: "Previous", disabled: false}) if @props.prev_page

    for page,i in pages
      # Add divider if this page is the beginning of a chunk:
      page_links.push({dotdotdot: true}) if i > 0 && pages[i-1] != page-1
      # Add page link:
      page_links.push({label: page, page: page, title: "Page #{page}", disabled: page == @props.current_page})

    # Add final > link
    page_links.push({label: "&gt;", page: @props.next_page, title: "Next", disabled: false}) if @props.next_page?

    <ul className="pagination">
    { for link, i in page_links
        if link.dotdotdot?
          <li key={i} className="divider" />

        else if link.disabled
          <li key={i} className="disabled"><span dangerouslySetInnerHTML={{__html: link.label }} /></li>

        else
          <li key={i}><a href={@pageUrl(link.page)} title={link.title} dangerouslySetInnerHTML={{__html: link.label }} /></li>
    }
    </ul>
