class Resb::Proxy::Core::Base
  class << self
    def attr_reader(*args)
      args = merge_serializable_props(self.serializable_attrs, args)

      super(*args)
    end

    def attr_accessor(*args)
      args = merge_serializable_props(self.serializable_attrs, args)
      super(*args)
    end

    def node_reader(*args)
      args = merge_serializable_props(self.serializable_nodes, args)

      method(:attr_reader).super_method.call(*args)
    end

    def node_accessor(*args)
      args = merge_serializable_props(self.serializable_nodes, args)

      method(:attr_accessor).super_method.call(*args)
    end

    def serializable_attrs
      @serializable_attrs ||= {}
    end

    def serializable_nodes
      @serializable_nodes ||= {}
    end

    def inherited(subclass)
      subclass.instance_variable_set '@serializable_attrs', self.serializable_attrs.clone
      subclass.instance_variable_set '@serializable_nodes', self.serializable_nodes.clone
    end

    def to_bool(value)
      if value.is_a?(String)
        value = value.strip
        value == 'true' || value == '1'
      else
        !!value
      end
    end

    def to_array(value)
      return value if value.is_a?(Array) || value.nil?

      return value.strip.split(' ') if value.is_a?(String)
      raise ArgumentError.new("Unknown argument's class")
    end

    def get_node(node, name)
      list = node.xpath("./#{name.to_s.sub(/^_/, '')}")
      return nil if list.empty?
      list
    end

    def common_type?(klass)
      %w(String Fixnum Float BigDecimal TrueClass FalseClass NilClass).include?(klass.to_s)
    end

    def unserialize_node(xml, opts={})
      if (xml.key?('nil') || xml.key?('xsi:nil')) && (self.to_bool(xml['nil'] || xml['xsi:nil']))
        return nil
      end

      if xml.elements.size == 0 || (opts[:class].present? && self.common_type?(opts[:class]))
        xml.content
      else
        klass = opts[:class] || xml.name.gsub('-', '_').camelize

        if opts.key?(:class)
          klass = opts[:class]
        else
          klass = xml.name.gsub('-', '_')

          if Resb::Esb.class_mapper.key?(klass)
            klass = Resb::Esb.class_mapper[klass]
          else
            klass = "Resb::Proxy::Core::#{klass.camelize}".safe_constantize || "Resb::Proxy::#{klass.camelize}".safe_constantize
          end
        end

        if klass.nil?
          raise Resb::Esb::EsbUnknownClass.new "Unknown class of the '#{xml.name}' node"
        end

        k = klass.new
        k.unserialize(xml)
        k
      end
    end

    def serialize_node(name, value, xml_doc, opts={})
      if opts[:array]
        value = Array.wrap(value)
      end

      path = name.split('/')
      elem = nil
      first_elem = nil
      path.each do |p|
        p = Nokogiri::XML::Element.new(p.gsub('_', '-'), xml_doc)
        first_elem ||= p
        if elem.present?
          elem << p
        end
        elem = p
      end

      if value.nil? && opts[:nil]
        elem['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
        elem['xsi:nil'] = 'true'
        return first_elem
      end

      return nil if value.nil?

      if opts[:array] && value.size == 0
        return first_elem
      end

      if value.class < Resb::Proxy::Core::Base
        value.serialize(elem, xml_doc)
        return first_elem
      end

      if value.is_a?(Array) && opts[:array]
        node_set = Nokogiri::XML::NodeSet.new(xml_doc) do |set|
          value.each do |it|
            _v = self.serialize_node(path.last, it, xml_doc, nil: opts[:nil])
            if _v.present?
              set << _v
            end
          end
        end

        if path.size == 1
          return node_set
        else
          elem << node_set
          return first_elem
        end
      end

      elem.content = self.serialize_value(value)
      first_elem
    end

    def serialize_value(value)
      if value.is_a?(Array)
        value.map { |v| self.serialize_value(v) }.join(' ')
      elsif value.nil?
        nil
      else
        value.to_s
      end
    end

    private

    def merge_serializable_props(prop, args)
      if args.first.is_a?(Hash)
        args.first.each do |k, v|
          prop[k] = v
        end
        return args.first.keys
      end

      if args.last.is_a?(Hash)
        prop[args.first] = args.last
        return [args.first]
      end

      args.each do |it|
        prop[it] = {}
      end
    end
  end

  def unserialize_attrs(xml)
    self.class.serializable_attrs.each do |(attr, opts)|
      _attr = attr.to_s
      if opts.present? && opts.has_key?(:name)
        _attr = opts[:name].to_s
      end

      next unless xml.key?(_attr)
      value = xml[_attr]
      next if value.nil?
      next if value.is_a?(Hash) || value.is_a?(Array)

      self.send("#{attr}=", value)
    end
  end

  def unserialize_nodes(xml)
    self.class.serializable_nodes.each do |(node, opts)|
      _node = node.to_s
      if opts.present? && opts.has_key?(:name)
        _node = opts[:name].to_s
      end

      xml_obj = self.class.get_node(xml, _node)
      next if xml_obj.nil?

      if opts[:array]
        if !xml_obj.is_a?(Nokogiri::XML::NodeSet) && !xml_obj.is_a?(Array)
          xml_obj = Array.wrap(xml_obj)
        end
      elsif xml_obj.is_a?(Nokogiri::XML::NodeSet) || xml_obj.is_a?(Array)
        xml_obj = Array.wrap(xml_obj.first)
      end

      value = []
      xml_obj.each do |it|
        value << self.class.unserialize_node(it, opts)
      end

      unless opts[:array]
        value = value.first
      end

      self.send("#{node}=", value)
    end
  end

  def unserialize(xml)
    self.unserialize_attrs(xml)
    self.unserialize_nodes(xml)
  end


  def serialize(elem, xml_doc)
    self.class.serializable_attrs.each do |(attr, opts)|
      _attr = attr.to_s
      if opts.present? && opts.has_key?(:name)
        _attr = opts[:name].to_s
      end

      value = self.send(attr)
      value = self.class.serialize_value(value)
      unless value.nil?
        elem[_attr] = value
      end
    end

    self.class.serializable_nodes.each do |(node, opts)|
      _node = node.to_s
      if opts.present? && opts.has_key?(:name)
        _node = opts[:name].to_s
      end

      value = self.send(node)

      value = self.class.serialize_node(_node, value, xml_doc, opts)
      elem << value if value.present?
    end

    elem
  end
end