module ApplicationHelper
  def form_field_error(object, field, options={})
    content_tag :span, "#{field.to_s.humanize} #{object.errors[field].first}.",
                class: "text-danger" unless object.errors[field].empty?
  end
end
