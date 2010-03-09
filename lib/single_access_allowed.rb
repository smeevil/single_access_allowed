class ApplicationController < ActionController::Base
  def self.inherited(klass)
    super
    klass.extend(ClassMethods)
    class << klass
      attr_accessor :single_access_options
    end
  end
 
  module ClassMethods
    def single_access_allowed(options=nil)
      self.single_access_options=options
      include(SingleAccessAllowed)
      self.disable_protect_from_forgery(options)
    end
    
    def disable_protect_from_forgery(options)
      if !options.kind_of?(Hash)
        RAILS_DEFAULT_LOGGER.info "disabling protect_from_forgery on #{self.name} for all actions"
        protect_from_forgery :only => []
      elsif options[:only].present?
        RAILS_DEFAULT_LOGGER.info "protect_from_forgery on #{self.name} except for #{options[:only].inspect}"
        protect_from_forgery :except => options[:only]
      elsif options[:except].present?
        RAILS_DEFAULT_LOGGER.info "protect_from_forgery on #{self.name} only for #{options[:except].inspect}"
        protect_from_forgery :only => options[:except]
      end
    end
  end
 
  module SingleAccessAllowed
    def single_access_allowed?
      options=self.class.single_access_options
      return true unless options.kind_of?(Hash)
      return [options[:except]].flatten.compact.index(params[:action].to_sym).nil? if options[:except].present?
      return [options[:only]].flatten.compact.include?(params[:action].to_sym)
    end
  end
end