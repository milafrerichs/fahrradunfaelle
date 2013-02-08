DataTypes = 
  pro_tausend : 1
  pro_tausend_gewichtet : 2
  

$ ->
  
  class Land
    constructor: () ->
      @bundeslaender = []
      
     
  class Bundesland
    constructor: (@name,@land) ->
      @einwohner = 0
      @dichte = 0
      @verletzte = 0
      @verletzte_pro_tausend = 0
      @verletzte_pro_tausend_gewichtet = 0
      
    verletzte_text: (type = DataTypes.pro_tausend) ->
      millions = d3.format(",n")
      text = switch type
        when DataTypes.pro_tausend then d3.round(@verletzte_pro_tausend)+" Verletze pro 100.000 Einwohner. <br/>(Absolut: #{@verletzte}, Einwohner: #{millions(@einwohner)})"
        when DataTypes.pro_tausend_gewichtet then " Faktor #{d3.round(@verletzte_pro_tausend_gewichtet)}. <br/>Gewichtet nach Einwohnerdichte.<br/>(Absolut: #{@verletzte}, Dichte: #{d3.round(@dichte)})"
      text
  
  class DataViz
    constructor: () ->
      @deutschland = new Land()
      @domain_range = []
      @domain_range_gewichtet = []
  
    getData: () ->
      d3.json "/fahrrad/data/fahrradunfalle_deutschland.json", (data) =>
    
        data.forEach (bundesland) =>
          land = new Bundesland(bundesland.name,@deutschland)
          land.einwohner = bundesland.einwohner
          land.verletzte = bundesland.verletzte
          land.dichte = bundesland.dichte
          land.verletzte_pro_tausend = bundesland.verletzte_pro_tausend
          land.verletzte_pro_tausend_gewichtet = bundesland.verletzte_pro_tausend_gewichtet
          @domain_range.push(land.verletzte_pro_tausend)
          @domain_range_gewichtet.push(land.verletzte_pro_tausend_gewichtet)
          @deutschland.bundeslaender.push(land)
        @quantize = d3.scale.quantile().domain(@domain_range).range(d3.range(9))
        @quantize_gewichtet = d3.scale.quantile().domain(@domain_range_gewichtet).range(d3.range(9))
        @display()
    display: (type = DataTypes.pro_tausend) ->
      
      @deutschland.bundeslaender.forEach (bundesland) =>
        d3.select('#'+bundesland.name).attr('class', (d,i) =>
          switch type
            when DataTypes.pro_tausend
              'q'+@quantize(bundesland.verletzte_pro_tausend)+'-9'
            when DataTypes.pro_tausend_gewichtet 
              'q'+@quantize_gewichtet(bundesland.verletzte_pro_tausend_gewichtet)+'-9'
        )
        $("##{bundesland.name}").popover({ placement : "right", trigger : "hover", title : bundesland.name, html : true, container : "body", delay : { show: 500, hide: 100 } })
        .attr('data-content',bundesland.verletzte_text(type))
        
        
  
  d = new DataViz()
  d.getData()
  
  d3.select("select").on "change", () ->
    d.display(parseInt(@value))
