class Stats

	constructor: () ->
		@getStats()

	addAreaChart: (item) ->
		data = item.data
		unit = item.unit
		refRow = data[0].values
		id = item.id
		$target = $('.'+id+' .chart').first()
		w = $target.closest('.category').width()
		h = 0.8 * $target.closest('.category').height()
		colors = ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#e377c2"]

		# reset
		$target.empty()

		# layout
		margin = {top: 30, right: 30, bottom: 100, left: 60}
		margin2 = {top: h-70, right: 30, bottom: 20, left: 60}
		width = w - margin.left - margin.right
		height = h - margin.top - margin.bottom
		height2 = h - margin2.top - margin2.bottom

		# time scales
		formatDate = d3.time.format("%b %e, %Y %I:%M%p")
		x = d3.time.scale().range([0, width])
		x2 = d3.time.scale().range([0, width])
		y = d3.scale.linear().range([height, 0])
		y2 = d3.scale.linear().range([height2, 0])

		# brush
		drawCircles = () ->

		onbrush = () ->
			x.domain(if brush.empty() then x2.domain() else brush.extent())
			focus.selectAll(".area").attr("d", area)
			focus.selectAll(".line").attr("d", line)
			focus.select(".x.axis").call(xAxis)
		brush = d3.svg.brush()
			.x(x2)
			.on("brush", onbrush)

		# axis
		xAxis = d3.svg.axis().scale(x).orient("bottom")
		xAxis2 = d3.svg.axis().scale(x2).orient("bottom")
		yAxis = d3.svg.axis().scale(y).orient("left")

		# draw base chart
		area = d3.svg.area()
			.interpolate("linear")
			.x((d) -> return x(d.date))
			.y0(height)
			.y1((d) -> return y(d.value))

		line = d3.svg.line()
			.interpolate("linear")
			.x((d) -> return x(d.date))
			.y((d) -> return y(d.value))

		area2 = d3.svg.area()
			.interpolate("linear")
			.x((d) -> return x2(d.date))
			.y0(height2)
			.y1((d) -> return y2(d.value))

		svg = d3.select($target[0]).append("svg")
			.attr("width", width + margin.left + margin.right)
			.attr("height", height + margin.top + margin.bottom)

		svg.append("defs").append("clipPath")
				.attr("id", "clip")
			.append("rect")
				.attr("width", width)
				.attr("height", height)
				.attr("class", "clip-rect")

		focus = svg.append("g")
			.attr("class", "focus")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")")

		context = svg.append("g")
			.attr("class", "context")
			.attr("transform", "translate(" + margin2.left + "," + margin2.top + ")")

		# add data
		x.domain(d3.extent(refRow.map((d) -> return d.date)))
		y.domain([0, d3.max(refRow.map((d) -> return d.value))])
		x2.domain(x.domain())
		y2.domain(y.domain())

		# build chart
		$.each data, (i, row) ->
			focus.append("path")
				.datum(row.values)
				.attr("class", "area")
				.attr("d", area)
				.style("fill", colors[i%colors.length])

			focus.append("path")
				.datum(row.values)
				.attr("class", "line")
				.attr("d", line)
				.style("stroke", colors[i%colors.length])

			context.append("path")
				.datum(row.values)
				.attr("class", "area")
				.attr("d", area2)
				.style("fill", colors[i%colors.length])

		focus.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + height + ")")
			.call(xAxis)

		focus.append("g")
			.attr("class", "y axis")
			.call(yAxis)

		context.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + height2 + ")")
			.call(xAxis2)

		context.append("g")
				.attr("class", "x brush")
				.call(brush)
			.selectAll("rect")
				.attr("y", -6)
				.attr("height", height2 + 7)

		# helpers
		focus.append("line")
			.attr("class", "helper x-line")
			.attr("y1", 0)
			.attr("y2", height)
			.style("opacity", 0)

		focus.append("text")
				.attr("class", "date helper")
				.attr("dx", "-5em")
				.attr("dy", "-1.2em")
				.style("opacity", 0)

		$.each data, (i, row) ->
			focus.append("circle")
				.attr("class", "helper row-"+i)
				.attr("r", 6)
				.style("opacity", 0)
				.style("fill", colors[i%colors.length])

			focus.append("text")
				.attr("class", "value helper row-"+i)
				.attr("dx", "-0.5em")
				.attr("dy", "1.4em")
				.style("opacity", 0)

		bisectDate = d3.bisector((d) -> return d.date).left

		onMousemove = () ->
			x0 = x.invert(d3.mouse(this)[0])
			x0 = x0 - margin.left
			$.each data, (i, row) ->
				j = bisectDate(row.values, x0, 1)
				d0 = row.values[j - 1]
				d1 = row.values[j]
				d = if x0 - d0.date > d1.date - x0 then d1 else d0
				date_text = d.value + "(" + formatDate(d.date) + ")"
				if i <= 0
					focus.select(".x-line")
						.transition()
						.duration(50)
						.attr("transform", "translate("+x(d.date)+","+y(d.value)+")")
						.attr("y2", height - y(d.value))
					focus.select("text.date")
						.transition()
						.duration(50)
						.attr("transform", "translate("+x(d.date)+","+y(d.value)+")")
						.text(formatDate(d.date))
				focus.select("circle.helper.row-"+i)
					.transition()
					.duration(50)
					.attr("transform", "translate("+x(d.date)+","+y(d.value)+")")
				focus.select("text.value.row-"+i)
					.transition()
					.duration(50)
					.attr("transform", "translate("+x(d.date)+","+y(d.value)+")")
					.text(d.value)

		focus.on("mousemove", onMousemove)
		focus.on("mouseover", () -> focus.selectAll(".helper").style("opacity", 1))
		focus.on("mouseout", () -> focus.selectAll(".helper").style("opacity", 0))

		# legend
		legendW = 100
		legendRowH = 20
		legendSymbolW = 10
		legendTop = 20
		legendRight = 30
		legend = svg.append("g")
			.attr("class", "legend")
			.attr("x", w - legendW- legendRight)
			.attr("y", legendTop)
			.attr("height", legendRowH*data.length)
			.attr("width", legendW)
		$.each data, (i, row) ->
			legend.append("rect")
				.attr("x", w - legendW- legendRight)
				.attr("y", legendTop + legendRowH * i - legendSymbolW)
				.attr("width", legendSymbolW)
				.attr("height", legendSymbolW)
				.style("fill", colors[i%colors.length])
			legend.append("text")
				.attr("x", w - legendW- legendRight + legendSymbolW*2)
				.attr("y", legendTop + legendRowH * i)
				.text(row.label)

		# init state
		duration = refRow[refRow.length-1].date - refRow[0].date
		if unit == 'week'
			range = 60 * 60 * 24 * 50 * 1000 # 50 days
		else if unit == 'day'
			range = 60 * 60 * 24 * 25 * 1000 # 25 days
		else
			range = 60 * 60 * 24 * 1000 # 24 hours
		if range > duration
			range = duration
		start = new Date(refRow[refRow.length-1].date - range)
		end = refRow[refRow.length-1].date
		brush.extent([start, end])
		onbrush()
		brush(svg.select(".brush").transition())
		brush.event(svg.select(".brush").transition().delay(1000))

	addChartListeners: () ->

		# scale charts on resize
		$(window).on "resize", () ->
			$('.chart').each () ->
				newWidth = $(this).width()
				$svg = $(this).find('svg')
				$parent = $svg.closest('.chart')
				svg = $svg[0]
				originalWidth = parseInt($svg.attr('width'))
				originalHeight = parseInt($svg.attr('height'))
				ratio = parseFloat(newWidth / originalWidth)
				transformString = "scale("+ratio+")"
				svg.style.webkitTransform = transformString
				svg.style.MozTransform = transformString
				svg.style.msTransform = transformString
				svg.style.OTransform = transformString
				svg.style.transform = transformString
				$parent.height(originalHeight*ratio)

		$('.units button').on "click", (e) =>
			e.preventDefault()
			$button = $(e.currentTarget)
			$button.siblings('button').removeClass('active')
			$button.addClass('active')
			item = @_findWhere(@data, 'id', $button.attr('data-category'))
			if item
				@addAreaChart(@groupData(item, $button.attr('data-group-by')))

	addPieChart: (item) ->
		data = item.data
		id = item.id
		$target = $('.'+id+' .chart').first()
		w = 0.8 * $target.closest('.category').width()
		h = 0.8 * $target.closest('.category').height()
		radius = Math.floor( Math.min(w, h) / 2 )
		color = d3.scale.category20c()
		total = 0

		$.each data, (i, obj) ->
			total += obj.value

		# create pies and arcs
		pie = d3.layout.pie()
			.sort(null)
			.value((d) -> return d.value)

		arc = d3.svg.arc()
			.outerRadius(radius * 0.8)
			.innerRadius(radius * 0.4)

		# create svg
		svg = d3.select($target[0]).append("svg")
				.attr("width", w)
				.attr("height", h)
			.append("g")
				.attr("transform", "translate(" + radius+ "," + radius + ")")

		# draw slices
		g = svg.selectAll(".arc")
				.data(pie(data))
			.enter().append("g")
				.attr("class", "arc")

		onMouseenter = (d) ->
			svg.select(".arc-center")
				.text(Math.round(d.value/total*100)+'%')

		g.append("path")
			.attr("d", arc)
			.style("fill", (d) -> return color(d.data.label))
			.on("mouseenter", onMouseenter)

		# center text
		svg.append("text")
			.attr("class", "arc-center")
			.style("text-anchor", "middle")
			.attr("dy", ".35em")
			.text(Math.round(data[0].value/total*100)+'%')

		# arc text
		g.append("text")
			.attr("transform", (d) -> return "translate(" + arc.centroid(d) + ")")
			.attr("dy", ".35em")
			.style("text-anchor", "middle")
			.text((d) -> return d.data.label)

	getStats: () ->
		$.getJSON "/projects/stats.json", (data) =>
			@data = @parseData(data.stats)
			@updateUI()
			@addChartListeners()

	recalculateStats: () ->
		$('.chart').empty()
		$.post "/admin/stats/recalculate.json", (data) =>
			@data = @parseData(data.stats)
			@updateUI()
			@addChartListeners()

	getFakeData: (amount, min, max) ->
		fake_data = []
		date = new Date(2015, 1, 1)
		for i in [0..amount] by 1
			value = Math.floor(Math.random() * max) + min
			fake_data.push {
				'date': date,
				'value': value
			}
			date = new Date(date.getTime() + 3600000)
		return fake_data

	groupData: (item, group_by) ->
		newItem = $.extend(true, {}, item)
		newData = []

		if group_by == "hour"
			newItem.unit = "hour"
			return newItem

		$.each newItem.data.slice(0), (i, v) =>
			# copy values and reset
			values = v.values.slice(0)
			newValues = []
			currentValues = []
			currentGroup = ''
			$.each values, (j, w) =>
				date = w.date
				# determine how to group
				if group_by == "week"
					group = @_getWeek(date)
				else
					group = @_getDay(date)
				# group has changed, add to new values
				if group != currentGroup or j >= values.length-1
					# end is reached
					if j >= values.length-1
						currentValues.push w
					# group is not empty
					if currentValues.length > 0
						newValue = {'date': currentValues[0].date}
						sum = 0
						$.each currentValues, (k, x) ->
							sum += x.value
						newValue.value = sum
						newValues.push newValue
					currentValues = []
					currentGroup = group
				# otherwise, add to group
				else
					currentValues.push w
			v.values = newValues
			newData.push v

		newItem.data = newData
		newItem.unit = group_by
		return newItem

	parseData: (data) ->
		# parse data
		parseDate = d3.time.format("%Y-%m-%d %H:%M").parse

		data.users.data.forEach (d) ->
			d.date = parseDate(d.date)
			d.value = +d.value

		data.classifications.data.forEach (d) ->
			d.date = parseDate(d.date)
			d.value = +d.value

		components = [
			{
				'id': 'classifications',
				'count': data.classifications.count,
				'type': 'area',
				'unit': 'hour',
				'data': [{
						'label': 'Classifications',
						'values': data.classifications.data
					}]
			},{
				'id': 'users',
				'count': data.users.count,
				'type': 'area',
				'unit': 'hour',
				'data': [{
						'label': 'Users',
						'values': data.users.data
					}]
			}
		]

		for name, d of data.workflow_counts
			components.push {
				'id': "#{name}-subjects",
				'count': d.total
				'type': 'pie',
				'data': d.data
			}
		components

	updateUI: () ->
		data = @data
		# go through each item in data
		$.each data, (i, item) =>

			# update counts
			$('.'+item.id+' .count').text @_formatNumber(item.count)

			# create graph
			if item.type == 'area'
				@addAreaChart(item)
			else if item.type == 'pie'
				@addPieChart(item)

	_findWhere: (arr, k, v) ->
		found = false
		$.each arr, (i, item) ->
			if item[k] == v
				found = $.extend(true, {}, item)
		return found

	_formatNumber: (n) ->
		return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

	_getDay: (d) ->
		return d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate()

	_getWeek: (_d) ->
		d = new Date(_d.getTime())
		d.setHours(0,0,0)
		d.setDate(d.getDate()+4-(d.getDay()||7))
		return d.getFullYear() + '-' + Math.ceil((((d-new Date(d.getFullYear(),0,1))/8.64e7)+1)/7)

$ ->
	window.stats = new Stats()
