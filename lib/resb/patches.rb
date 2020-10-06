module Resb
  class BasePatches
    class << self
      def dir
        'patches'
      end

      def load_all_dependencies
        Dir[File.join(File.dirname(__FILE__), dir, '**', '*.rb')].each do |file|
        patches_name_part = "#{dir.camelize}"
        obj_patch = File.join('resb', file.gsub(File.dirname(__FILE__), '').gsub(/\.rb$/, '')).camelize.safe_constantize
        next unless obj_patch

        if obj_patch.respond_to?(:target_object)
          obj = obj_patch.target_object
          next if obj.nil?
        else
          tmp = File.basename(file, '.rb').gsub(/\_patch$/, '')

          begin
            obj = tmp.camelize.safe_constantize
          rescue LoadError
            obj = nil
          end

          if obj.nil?
            begin
              obj = tmp.upcase.safe_constantize
            rescue LoadError
              obj = nil
            end
          end

          if obj.nil?
            begin
              obj = file.gsub(File.dirname(__FILE__), '').gsub(/\_patch\.rb$/, '').camelize.gsub(Regexp.new("^\:\:#{patches_name_part}\:\:"), '').safe_constantize
            rescue LoadError
              obj = nil
            end
          end

          if obj.nil?
            begin
              obj = file.gsub(File.dirname(__FILE__), '').gsub(/\_patch\.rb$/, '').camelize.gsub(Regexp.new("^\:\:#{patches_name_part}\:\:"), '').gsub("::#{tmp.camelize}", "::#{tmp.upcase}").safe_constantize
            rescue LoadError
              obj = nil
            end
          end
        end

        next unless obj

        next if obj.included_modules.include?(obj_patch)

        obj.send :include, obj_patch
      end
      end
    end
  end

  class Patches < BasePatches
  end

  class LatePatches < BasePatches
    def self.dir
      'late_patches'
    end
  end
end