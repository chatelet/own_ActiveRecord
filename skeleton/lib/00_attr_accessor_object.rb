class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
      define_method("#{name}") do
        instance_variable_get("@#{name}")
      end
      define_method("#{name}=") do |argument|
        #{}"#{name} = #{argument}"
        self.instance_variable_set("@#{name}", argument)
      end
    end
  end
end
