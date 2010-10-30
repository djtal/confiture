require 'rubygems'
require 'active_support'
require 'hpricot'
require 'open-uri'

module Confiture
  # Confiture : HTML scrapping made easy
  #
  # Map an HTML Scrapper onto a html page
  # Based on Hpricot parser by _Why
  #
  # Load a page
  #
  # To connect your Class to a page use the source macro
  # The source can either a local page or an uri
  #
  #
  # Define base pattern to find element on page
  #
  # Define the pattern to match all element on your page
  # To define this pattern, you can use 
  #   css selector syntax
  #   xpath syntax
  #
  # For this element, you can define somme attributes and some constraint on those attributes
  # The syntax for attribute pattern is the same as for global pattern.
  #
  #
  # Grab all element
  # Use the find method on your class
  # Ex :If You define a Post class use Post.find to grab all Post element on your page
  #
  class Base
    cattr_accessor :attribute_patterns
    @@attribute_patterns = {}
    
    # hold an instance of Hpricot parser use to find element on source.
    cattr_accessor :doc
    
    attr_accessor :element
    
    def initialize(el = nil)
      @element = el
      extract_attributes
    end
    
    def /(pattern)
      element/pattern
    end
    
    # check constraint on element
    def valid?
      mandatory_fields = attribute_patterns.map{ |attr, v| attr if (v.include?(:mandatory) && v[:mandatory])}
      mandatory_fields.compact.inject(true) do |acc, field|
        acc = acc && !(self.send(field).blank?)
      end
    end
    
    # Extract attributes from attributes_pattern hash
    # and assign result to coresponding instance variable
    #
    def extract_attributes
      unless element.nil?
        @@attribute_patterns.each do |attr, pattern|
           send("#{attr}=", (element/pattern[:pattern]).text.strip)
        end
      end
    end

    class << self
      
      # set the document source for class
      # can be either a file or a uri
      #
      def source(src)
        @@doc = open(src){ |f| Hpricot(f) }
      end
      
      # Define the global pattern to match element of your class onto the page
      # The patter can be either:
      # a css selector expression : html > body > p img"
      # or
      # a xpath expression : html/body/p/img
      #
      # call pattern automaticaly create a classname_apattern accessor for your conveniance
      def pattern(pattern)
        instance_eval(<<-EOS, __FILE__, __LINE__)
          def #{name.downcase}_pattern
            @@#{name.downcase}_pattern
          end

          def #{name.downcase}_pattern=(arg)
            @@#{name.downcase}_pattern = arg
          end
        EOS
        send("#{name.downcase}_pattern=", pattern)
      end
      
      # Define an attribute on element.
      # An attribute is identified by his name and his pattern
      # The format for pattern is same as global patern
      # Optionnaly you can specify constraints on attribute
      # Actually supported constraint are 
      # :mandatory => the element is valid only if attribut is present an not null
      #
      # It's also create accessor for attribute
      def attribute(sym, pattern, opts = {})
        attribute_patterns[sym] = {:pattern => pattern}.merge(opts)
        instance_eval(<<-EOS, __FILE__, __LINE__)
          def #{sym.to_s}_pattern
            attribute_patterns[:#{sym}][:pattern]
          end

          def #{sym.to_s}_pattern=(arg)
            attribute_patterns[:#{sym}][:pattern] = arg
          end
        EOS
        instance_eval do
          attr_accessor sym
        end
      end

      def attributes_fields
        attribute_patterns.map{ |k, v|  k}
      end
      
      # Forward global search to Hpricot
      # Ex to make a new search on source use
      # Post/"body"
      def /(pattern)
        @@doc/pattern
      end
      
      # Search all elements that match the given pattern throught the source
      # Return an array of elements if their have some defined
      # Return empty array if no source defined.
      def find
        return [] if doc.nil?
        pattern = send("#{name.downcase}_pattern")
        els = (doc/pattern).inject([]){ |els, subset| els << self.new(subset)}
        els.reject!{ |el| !el.valid?}
        els
      end
      
      def each
        find.each { |el| yield el}
      end
      
      def parse(src)
        self.source(src)
        self.find
      end
    end
  end  
end
