Redmine::Plugin.register :rmplus_esb do
  name 'RMPlus ESB plugin'
  author 'Kovalevsky Vasil'
  description ''
  version '1.0.0'
  url ''
  author_url ''

  requires_redmine '4.0.0'

  settings partial: 'rmplus_esb/settings',
           default: {}

  project_module :rmplus_esb do
    permission :esb_access, esb: [:package]
  end

  menu :admin_menu, :resb_trade_points, { controller: :resb_trade_points, action: :index }, caption: :label_resb_trade_points_plural, html: { class: 'rm-icon fa-hospital-o' }
end
Rails.application.config.to_prepare do
  load 'resb/loader.rb'
end

Rails.application.config.after_initialize do
  Resb::LatePatches.load_all_dependencies
  ActiveSupport::Reloader.to_prepare do
    Resb::LatePatches.load_all_dependencies
  end

  plugins = { a_common_libs: '2.5.4', global_roles: '2.2.5', ldap_users_sync: '2.7.2' }
  kpi = Redmine::Plugin.find(:rmplus_esb)
  plugins.each do |k,v|
    begin
      kpi.requires_redmine_plugin(k, v)
    rescue Redmine::PluginNotFound => ex
      raise(Redmine::PluginNotFound, "Plugin requires #{k} not found")
    end
  end
end
