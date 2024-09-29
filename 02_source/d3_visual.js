// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//
// set up constants used throughout script
const margin = {top: 80, right: 100, bottom: 40, left: 60}
const plotWidth = 800 - margin.left - margin.right
const plotHeight = 400 - margin.top - margin.bottom

const lineWidth = 3
const mediumText = 18
const bigText = 28

// set width and height of svg element (plot + margin)
svg.attr("width", plotWidth + margin.left + margin.right)
   .attr("height", plotHeight + margin.top + margin.bottom)
   
// create plot group and move it
let plotGroup = svg.append("g")
                   .attr("transform",
                         "translate(" + margin.left + "," + margin.top + ")")
                         
                         // x-axis values to year range in data
// x-axis goes from 0 to width of plot
let xAxis = d3.scaleLinear()
    .domain(d3.extent(data, d => { return d.year; }))
    .range([ 0, plotWidth ]);
    
// y-axis values to cumulative caught range
// y-axis goes from height of plot to 0
let yAxis = d3.scaleLinear()
    .domain(d3.extent(data, d => { return d.cumulative_caught; }))
    .range([ plotHeight, 0]);
    
    
let path = plotGroup.selectAll(".drawn_lines")
    .data(data)
    .enter()
    .append("path")
    // set up class so only this path element can be removed
    .attr("class", "drawn_lines")
    .attr("fill", "none")
    // color of lines from hex codes in data
    .attr("stroke", "yellow") 
    .attr("stroke-width", lineWidth)
     // draw line according to data
    .attr("d", d => {
      return d3.line()
        .x(d => { return xAxis(d.year);})
        .y(d => { return yAxis(d.cumulative_caught);})
        d
    })
    


