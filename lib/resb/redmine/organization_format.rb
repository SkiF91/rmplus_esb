module Redmine::FieldFormat
  class OrganisationFormat < RecordList
    add 'resb_organisation'
    self.form_partial = 'custom_fields/formats/organisation'
    self.ajax_supported = true

    def target_class
      ResbOrganization
    end

    def possible_values_options(custom_field, object=nil)
      possible_values_records(custom_field, object).map {|u| [u.name, u.id.to_s]}
    end

    def possible_values_records(custom_field, object=nil, like=nil, vals=nil)
      scope = ResbOrganization.active.sorted.select(*ResbOrganization.fields_for_order_statement)

      if vals.present?
        scope = scope.where(id: vals)
      elsif like.present?
        scope = scope.like(like)
      end

      if block_given?
        scope.each do |it|
          yield(it, it.id, it.name)
        end
      end

      scope
    end

  end
end