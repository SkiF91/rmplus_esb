require_dependency 'resb/esb'
Dir[File.join(Rails.root, 'plugins', 'rmplus_esb', 'lib', 'resb', 'proxy', '**', '*.rb')].each { |file| require_dependency file }

require 'resb/ldap_dep_title_ext'
require 'resb'
require 'resb/hooks/view_hooks'

require 'resb/patches'

require_dependency 'resb/redmine/organization_format'
Resb::Patches.load_all_dependencies