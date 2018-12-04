import $ from 'jquery';

class Stats {
  constructor() {
    this.getStats();
  }

  addAreaChart(item) {
    let range;
    const { data } = item;
    const { unit } = item;
    const refRow = data[0].values;
    const { id } = item;
    const $target = $(`.${id} .chart`).first();
    const w = $target.closest(".category").width();
    const h = 0.8 * $target.closest(".category").height();
    const colors = [
      "#1f77b4",
      "#ff7f0e",
      "#2ca02c",
      "#d62728",
      "#9467bd",
      "#e377c2"
    ];

    // reset
    $target.empty();

    // layout
    const margin = { top: 30, right: 30, bottom: 100, left: 60 };
    const margin2 = { top: h - 70, right: 30, bottom: 20, left: 60 };
    const width = w - margin.left - margin.right;
    const height = h - margin.top - margin.bottom;
    const height2 = h - margin2.top - margin2.bottom;

    // time scales
    const formatDate = d3.time.format("%b %e, %Y %I:%M%p");
    const x = d3.time.scale().range([0, width]);
    const x2 = d3.time.scale().range([0, width]);
    const y = d3.scale.linear().range([height, 0]);
    const y2 = d3.scale.linear().range([height2, 0]);

    // brush
    const drawCircles = function () { };

    const onbrush = function () {
      x.domain(brush.empty() ? x2.domain() : brush.extent());
      focus.selectAll(".area").attr("d", area);
      focus.selectAll(".line").attr("d", line);
      return focus.select(".x.axis").call(xAxis);
    };
    var brush = d3.svg
      .brush()
      .x(x2)
      .on("brush", onbrush);

    // axis
    var xAxis = d3.svg
      .axis()
      .scale(x)
      .orient("bottom");
    const xAxis2 = d3.svg
      .axis()
      .scale(x2)
      .orient("bottom");
    const yAxis = d3.svg
      .axis()
      .scale(y)
      .orient("left");

    // draw base chart
    var area = d3.svg
      .area()
      .interpolate("linear")
      .x((d) => x(d.date))
      .y0(height)
      .y1((d) => y(d.value));

    var line = d3.svg
      .line()
      .interpolate("linear")
      .x(d => x(d.date))
      .y(d => y(d.value));

    const area2 = d3.svg
      .area()
      .interpolate("linear")
      .x(d => x2(d.date))
      .y0(height2)
      .y1(d => y2(d.value));

    const svg = d3
      .select($target[0])
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom);

    svg
      .append("defs")
      .append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("width", width)
      .attr("height", height)
      .attr("class", "clip-rect");

    var focus = svg
      .append("g")
      .attr("class", "focus")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    const context = svg
      .append("g")
      .attr("class", "context")
      .attr("transform", `translate(${margin2.left},${margin2.top})`);

    // add data
    x.domain(d3.extent(refRow.map(d => d.date)));
    y.domain([0, d3.max(refRow.map(d => d.value))]);
    x2.domain(x.domain());
    y2.domain(y.domain());

    // build chart
    $.each(data, function (i, row) {
      focus
        .append("path")
        .datum(row.values)
        .attr("class", "area")
        .attr("d", area)
        .style("fill", colors[i % colors.length]);

      focus
        .append("path")
        .datum(row.values)
        .attr("class", "line")
        .attr("d", line)
        .style("stroke", colors[i % colors.length]);

      return context
        .append("path")
        .datum(row.values)
        .attr("class", "area")
        .attr("d", area2)
        .style("fill", colors[i % colors.length]);
    });

    focus
      .append("g")
      .attr("class", "x axis")
      .attr("transform", `translate(0,${height})`)
      .call(xAxis);

    focus
      .append("g")
      .attr("class", "y axis")
      .call(yAxis);

    context
      .append("g")
      .attr("class", "x axis")
      .attr("transform", `translate(0,${height2})`)
      .call(xAxis2);

    context
      .append("g")
      .attr("class", "x brush")
      .call(brush)
      .selectAll("rect")
      .attr("y", -6)
      .attr("height", height2 + 7);

    // helpers
    focus
      .append("line")
      .attr("class", "helper x-line")
      .attr("y1", 0)
      .attr("y2", height)
      .style("opacity", 0);

    focus
      .append("text")
      .attr("class", "date helper")
      .attr("dx", "-5em")
      .attr("dy", "-1.2em")
      .style("opacity", 0);

    $.each(data, function (i, row) {
      focus
        .append("circle")
        .attr("class", `helper row-${i}`)
        .attr("r", 6)
        .style("opacity", 0)
        .style("fill", colors[i % colors.length]);

      return focus
        .append("text")
        .attr("class", `value helper row-${i}`)
        .attr("dx", "-0.5em")
        .attr("dy", "1.4em")
        .style("opacity", 0);
    });

    const bisectDate = d3.bisector(d => d.date).left;

    const onMousemove = function () {
      let x0 = x.invert(d3.mouse(this)[0]);
      x0 = x0 - margin.left;
      return $.each(data, function (i, row) {
        const j = bisectDate(row.values, x0, 1);
        const d0 = row.values[j - 1];
        const d1 = row.values[j];
        const d = x0 - d0.date > d1.date - x0 ? d1 : d0;
        const date_text = d.value + "(" + formatDate(d.date) + ")";
        if (i <= 0) {
          focus
            .select(".x-line")
            .transition()
            .duration(50)
            .attr("transform", `translate(${x(d.date)},${y(d.value)})`)
            .attr("y2", height - y(d.value));
          focus
            .select("text.date")
            .transition()
            .duration(50)
            .attr("transform", `translate(${x(d.date)},${y(d.value)})`)
            .text(formatDate(d.date));
        }
        focus
          .select(`circle.helper.row-${i}`)
          .transition()
          .duration(50)
          .attr("transform", `translate(${x(d.date)},${y(d.value)})`);
        return focus
          .select(`text.value.row-${i}`)
          .transition()
          .duration(50)
          .attr("transform", `translate(${x(d.date)},${y(d.value)})`)
          .text(d.value);
      });
    };

    focus.on("mousemove", onMousemove);
    focus.on("mouseover", () => focus.selectAll(".helper").style("opacity", 1));
    focus.on("mouseout", () => focus.selectAll(".helper").style("opacity", 0));

    // legend
    const legendW = 100;
    const legendRowH = 20;
    const legendSymbolW = 10;
    const legendTop = 20;
    const legendRight = 30;
    const legend = svg
      .append("g")
      .attr("class", "legend")
      .attr("x", w - legendW - legendRight)
      .attr("y", legendTop)
      .attr("height", legendRowH * data.length)
      .attr("width", legendW);
    $.each(data, function (i, row) {
      legend
        .append("rect")
        .attr("x", w - legendW - legendRight)
        .attr("y", legendTop + legendRowH * i - legendSymbolW)
        .attr("width", legendSymbolW)
        .attr("height", legendSymbolW)
        .style("fill", colors[i % colors.length]);
      return legend
        .append("text")
        .attr("x", w - legendW - legendRight + legendSymbolW * 2)
        .attr("y", legendTop + legendRowH * i)
        .text(row.label);
    });

    // init state
    const duration = refRow[refRow.length - 1].date - refRow[0].date;
    if (unit === "week") {
      range = 60 * 60 * 24 * 50 * 1000; // 50 days
    } else if (unit === "day") {
      range = 60 * 60 * 24 * 25 * 1000; // 25 days
    } else {
      range = 60 * 60 * 24 * 1000; // 24 hours
    }
    if (range > duration) {
      range = duration;
    }
    const start = new Date(refRow[refRow.length - 1].date - range);
    const end = refRow[refRow.length - 1].date;
    brush.extent([start, end]);
    onbrush();
    brush(svg.select(".brush").transition());
    return brush.event(
      svg
        .select(".brush")
        .transition()
        .delay(1000)
    );
  }

  addChartListeners() {
    // scale charts on resize
    $(window).on("resize", () =>
      $(".chart").each(function () {
        const newWidth = $(this).width();
        const $svg = $(this).find("svg");
        const $parent = $svg.closest(".chart");
        const svg = $svg[0];
        const originalWidth = parseInt($svg.attr("width"));
        const originalHeight = parseInt($svg.attr("height"));
        const ratio = parseFloat(newWidth / originalWidth);
        const transformString = `scale(${ratio})`;
        svg.style.webkitTransform = transformString;
        svg.style.MozTransform = transformString;
        svg.style.msTransform = transformString;
        svg.style.OTransform = transformString;
        svg.style.transform = transformString;
        return $parent.height(originalHeight * ratio);
      })
    );

    return $(".units button").on("click", e => {
      e.preventDefault();
      const $button = $(e.currentTarget);
      $button.siblings("button").removeClass("active");
      $button.addClass("active");
      const item = this._findWhere(
        this.data,
        "id",
        $button.attr("data-category")
      );
      if (item) {
        return this.addAreaChart(
          this.groupData(item, $button.attr("data-group-by"))
        );
      }
    });
  }

  addPieChart(item) {
    const { data } = item;
    const { id } = item;
    const $target = $(`.${id} .chart`).first();
    const w = 0.8 * $target.closest(".category").width();
    const h = 0.8 * $target.closest(".category").height();
    const radius = Math.floor(Math.min(w, h) / 2);
    const color = d3.scale.category20c();
    let total = 0;

    $.each(data, (i, obj) => (total += obj.value));

    // create pies and arcs
    const pie = d3.layout
      .pie()
      .sort(null)
      .value(d => d.value);

    const arc = d3.svg
      .arc()
      .outerRadius(radius * 0.8)
      .innerRadius(radius * 0.4);

    // create svg
    const svg = d3
      .select($target[0])
      .append("svg")
      .attr("width", w)
      .attr("height", h)
      .append("g")
      .attr("transform", `translate(${radius},${radius})`);

    // draw slices
    const g = svg
      .selectAll(".arc")
      .data(pie(data))
      .enter()
      .append("g")
      .attr("class", "arc");

    const onMouseenter = d =>
      svg.select(".arc-center").text(Math.round((d.value / total) * 100) + "%");

    g.append("path")
      .attr("d", arc)
      .style("fill", d => color(d.data.label))
      .on("mouseenter", onMouseenter);

    // center text
    svg
      .append("text")
      .attr("class", "arc-center")
      .style("text-anchor", "middle")
      .attr("dy", ".35em")
      .text(Math.round((data[0].value / total) * 100) + "%");

    // arc text
    return g
      .append("text")
      .attr("transform", d => `translate(${arc.centroid(d)})`)
      .attr("dy", ".35em")
      .style("text-anchor", "middle")
      .text(d => d.data.label);
  }

  getStats() {
    return $.getJSON("/projects/stats.json", data => {
      this.data = this.parseData(data.stats);
      this.updateUI();
      return this.addChartListeners();
    });
  }

  recalculateStats() {
    $(".chart").empty();
    return $.post("/admin/stats/recalculate.json", data => {
      this.data = this.parseData(data.stats);
      this.updateUI();
      return this.addChartListeners();
    });
  }

  getFakeData(amount, min, max) {
    const fake_data = [];
    let date = new Date(2015, 1, 1);
    for (let i = 0, end = amount; i <= end; i++) {
      const value = Math.floor(Math.random() * max) + min;
      fake_data.push({
        date: date,
        value: value
      });
      date = new Date(date.getTime() + 3600000);
    }
    return fake_data;
  }

  groupData(item, group_by) {
    const newItem = $.extend(true, {}, item);
    const newData = [];

    if (group_by === "hour") {
      newItem.unit = "hour";
      return newItem;
    }

    $.each(newItem.data.slice(0), (i, v) => {
      // copy values and reset
      const values = v.values.slice(0);
      const newValues = [];
      let currentValues = [];
      let currentGroup = "";
      $.each(values, (j, w) => {
        let group;
        const { date } = w;
        // determine how to group
        if (group_by === "week") {
          group = this._getWeek(date);
        } else {
          group = this._getDay(date);
        }
        // group has changed, add to new values
        if (group !== currentGroup || j >= values.length - 1) {
          // end is reached
          if (j >= values.length - 1) {
            currentValues.push(w);
          }
          // group is not empty
          if (currentValues.length > 0) {
            const newValue = { date: currentValues[0].date };
            let sum = 0;
            $.each(currentValues, (k, x) => (sum += x.value));
            newValue.value = sum;
            newValues.push(newValue);
          }
          currentValues = [];
          return (currentGroup = group);
          // otherwise, add to group
        } else {
          return currentValues.push(w);
        }
      });
      v.values = newValues;
      return newData.push(v);
    });

    newItem.data = newData;
    newItem.unit = group_by;
    return newItem;
  }

  parseData(data) {
    // parse data
    const parseDate = d3.time.format("%Y-%m-%d %H:%M").parse;

    data.users.data.forEach(function (d) {
      d.date = parseDate(d.date);
      return (d.value = +d.value);
    });

    data.classifications.data.forEach(function (d) {
      d.date = parseDate(d.date);
      return (d.value = +d.value);
    });

    const components = [
      {
        id: "classifications",
        count: data.classifications.count,
        type: "area",
        unit: "hour",
        data: [
          {
            label: "Classifications",
            values: data.classifications.data
          }
        ]
      },
      {
        id: "users",
        count: data.users.count,
        type: "area",
        unit: "hour",
        data: [
          {
            label: "Users",
            values: data.users.data
          }
        ]
      }
    ];

    for (let name in data.workflow_counts) {
      const d = data.workflow_counts[name];
      components.push({
        id: `${name}-subjects`,
        count: d.total,
        type: "pie",
        data: d.data
      });
    }
    return components;
  }

  updateUI() {
    const { data } = this;
    // go through each item in data
    return $.each(data, (i, item) => {
      // update counts
      $(`.${item.id} .count`).text(this._formatNumber(item.count));

      // create graph
      if (item.type === "area") {
        return this.addAreaChart(item);
      } else if (item.type === "pie") {
        return this.addPieChart(item);
      }
    });
  }

  _findWhere(arr, k, v) {
    let found = false;
    $.each(arr, function (i, item) {
      if (item[k] === v) {
        return (found = $.extend(true, {}, item));
      }
    });
    return found;
  }

  _formatNumber(n) {
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

  _getDay(d) {
    return d.getFullYear() + "-" + d.getMonth() + "-" + d.getDate();
  }

  _getWeek(_d) {
    const d = new Date(_d.getTime());
    d.setHours(0, 0, 0);
    d.setDate(d.getDate() + 4 - (d.getDay() || 7));
    return (
      d.getFullYear() +
      "-" +
      Math.ceil(((d - new Date(d.getFullYear(), 0, 1)) / 8.64e7 + 1) / 7)
    );
  }
}

$(() => (window.stats = new Stats()));
