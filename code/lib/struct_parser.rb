require 'ostruct'

class StructParser

  def call(arr)
    data = arr.map do |line|
      line.chomp.split(/\t/)
    end
    headers = data.shift
    data.map do |tuple|
      OpenStruct.new(
        Hash[
          headers.zip(tuple)
        ]
      )
    end
  end

end
