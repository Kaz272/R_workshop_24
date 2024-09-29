var barHeight = Math.floor(height / data.length * 0.9);

svg
  .selectAll("rect")
  .data(data)
  .enter()
  .append("rect")
  .attr("width",barHeight)
  .attr("height",  function (d) {
    return d * width;
  })
  .attr("x", function (d, i) {
    return i * barHeight;
  })
  .attr("y", height)
  .attr("fill", "steelblue");