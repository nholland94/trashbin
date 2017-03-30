class MassObject

  def self.my_attr_accessible(*attributes)
    attributes.each do |variable|
      attr_accessor variable

      # instance_variable_set("@#{key}", val)
    end

    @attributes = attributes
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    objects = []

    results.each do |row|
      objects << new(row)
    end

    objects
  end

  def initialize(params = {})
    # self.class.my_attr_accessible(params)

    params.each_pair do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name.to_s}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end