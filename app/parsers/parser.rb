module Parser

  module ClassMethods

    def set_authentication_details(attributes)
      self.authentication_details = attributes
    end

  end

  class Base

    class << self
      attr_accessor :authentication_details, :expressions
    end

    @authentication_details = { :address => nil, :params => [] }
    @expressions = []

    def self.inherited(child)
      child.extend(Parser::ClassMethods)
    end

  end

end
