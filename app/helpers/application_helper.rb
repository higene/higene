module ApplicationHelper
  def title(page_title = nil)
    if page_title.nil?
      content_for :title, "HiGene"
    else
      content_for :title, "#{page_title} - HiGene"
    end
  end

  def form_field_error(object, field, options={})
    content_tag :span, "#{field.to_s.humanize} #{object.errors[field].first}.",
                class: "text-danger" unless object.errors[field].empty?
  end
end
