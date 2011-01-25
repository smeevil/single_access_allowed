require 'single_access_allowed'

config.after_initialize do
  ::ActionController::Base.send(:include, SingleAccessAllowed)
end
