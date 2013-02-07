$ ->
  
  class Land
    constructor: () ->
      @bundeslaender = []
      
     
  class Bundesland
    constructor: (@name,@land) ->
      @einwohner = 0
      @dichte = 0
      @verletzte = 0
      @pro_tausend = 0
      
    verletzte_pro_tausend: () ->
      @pro_tausend = (100000 * @verletzte ) / @einwohner
    
    verletzte_text: () ->
      d3.round(@pro_tausend)+" Verletze pro 100.000 Einwohner"
  
  d3.json "/fahrrad/data/fahrradunfalle_deutschland.json", (data) ->
    deutschland = new Land()
    domain_range = []
    data.forEach (bundesland) ->
      land = new Bundesland(bundesland.bundesland,deutschland)
      land.einwohner = bundesland.einwohner
      land.verletzte = bundesland.verletze
      land.dichte = bundesland.dichte
      land.verletzte_pro_tausend()
      domain_range.push(land.pro_tausend)
      deutschland.bundeslaender.push(land)
    quantize = d3.scale.quantile().domain(domain_range).range(d3.range(9))
    
    deutschland.bundeslaender.forEach (bundesland) ->
      d3.select('#'+bundesland.name).attr('class', (d,i) ->
        'q'+quantize(bundesland.pro_tausend)+'-9'
      ).append("svg:title").text( (d) -> 
        bundesland.verletzte_text()
      )
    
    
      