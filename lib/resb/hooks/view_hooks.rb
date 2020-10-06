module Resb::Hooks
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_kpi_custom_indicators_form_fields, partial: 'hooks/rmplus_esb/view_kpi_custom_indicators_form_fields'
  end
end