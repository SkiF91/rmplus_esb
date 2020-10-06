module Resb::LatePatches::Models
  module SdRequestPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do

      end
    end

    module InstanceMethods

    end
  end
end