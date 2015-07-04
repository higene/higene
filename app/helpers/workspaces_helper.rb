module WorkspacesHelper
  def long_content_tag(content, limit = 200)
    unless content.nil?
      if content.length > limit
        content_tag :span,
                    truncate(content, length: limit),
                    data: {
                      toggle: "popover",
                      content: content,
                      placement: "bottom",
                      trigger: "manual"
                    }
      else
        content
      end
    end
  end
end
