require 'json'
class Land
  attr_accessor :name, :bundeslaender
  def initialize(name)
    @name = name
    @bundeslaender = []
  end
  def bundeslaender_dichte_average
    @bundeslaender.map { |x| x.dichte.to_f  }.inject(:+) / @bundeslaender.length
  end
end

class Bundesland
  attr_accessor :name, :einwohner, :dichte, :verletzte
  def initialize(name)
    @name = name
  end
  
  def to_hash
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    hash
  end
  
  
end


class CalculateData
  
  def initialize(filename = "fahrradunfalle_deutschland_raw.json")
    json_string = File.read(filename)
    @data = JSON.parse(json_string)
    @deutschland = Land.new("Deutschland")
    parseLaender
  end
  def parseLaender
    @data.each do |land|
      bundesland = Bundesland.new(land["bundesland"])
      bundesland.einwohner = land["einwohner"]
      bundesland.dichte = land["dichte"]
      bundesland.verletzte = land["verletze"]
      @deutschland.bundeslaender << bundesland
    end
  end
  
  def calculate_verletzte_pro_tausend(land)
    (100000 * land.verletzte ) / land.einwohner
  end
  def calculate_verletzte_pro_tausend_gewichtet(land,gewicht)
    calculate_verletzte_pro_tausend(land)*gewicht
  end
  
  def export
    dichte_mittel = @deutschland.bundeslaender_dichte_average
    export_json = []
    
    @deutschland.bundeslaender.each do |land|
      land_hash = land.to_hash
      land_hash[:verletzte_pro_tausend] = calculate_verletzte_pro_tausend(land)
      land_hash[:verletzte_pro_tausend_gewichtet] = calculate_verletzte_pro_tausend_gewichtet(land,(land.dichte/dichte_mittel))
      export_json << land_hash
    end
    File.open("fahrradunfalle_deutschland.json", 'w') { |file| file.write(export_json.to_json) }
  end
  
end

c = CalculateData.new
c.export
