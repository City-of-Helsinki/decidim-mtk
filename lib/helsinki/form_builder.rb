# frozen_string_literal: true

# Form builder extensions and overrides for the Decidim::FormBuilder to inject
# to that helper class.
module Helsinki
  class FormBuilder < Decidim::FormBuilder
    # Public: Override so checkboxes are rendered inside a "checkbox" div and
    # also not inside the label element as they would otherwise be with Decidim.
    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
      lbl = ""
      if options[:label] != false
        label_text = options.delete(:label)
        label_options = options.delete(:label_options) || {}
        lbl = label(attribute, label_text, label_options)
      end

      inner = (
        @template.check_box(@object_name, attribute, objectify_options(options), checked_value, unchecked_value) +
        lbl +
        error_and_help_text(attribute, options)
      )

      if options[:wrapper] == false
        inner
      else
        content_tag(:div, class: "checkbox") do
          inner
        end
      end
    end

    # Public: Override so radio buttons are rendered inside a "radio" div.
    def radio_button(attribute, tag_value, options = {})
      if options[:wrapper] == false
        super
      else
        content_tag(:div, class: "radio") do
          super
        end
      end
    end

    # Public: Generates a file upload field and sets the form as multipart.
    # If the file is an image it displays the default image if present or the current one.
    # By default it also generates a checkbox to delete the file. This checkbox can
    # be hidden if `options[:optional]` is passed as `false`.
    #
    # Overridden because otherwise <br> may be printed to the error fields.
    #
    # attribute    - The String name of the attribute to buidl the field.
    # options      - A Hash with options to build the field.
    #              * optional: Whether the file can be optional or not.
    def upload(attribute, options = {})
      self.multipart = true
      options[:optional] = options[:optional].nil? ? true : options[:optional]

      file = object.send attribute
      template = ""
      template += label(attribute, label_for(attribute) + required_for_attribute(attribute))
      template += @template.file_field @object_name, attribute

      if file_is_image?(file)
        template += if file.present?
                      @template.content_tag :label, I18n.t("current_image", scope: "decidim.forms")
                    else
                      @template.content_tag :label, I18n.t("default_image", scope: "decidim.forms")
                    end
        template += @template.link_to @template.image_tag(file.url), file.url, target: "_blank"
      elsif file_is_present?(file)
        template += @template.label_tag I18n.t("current_file", scope: "decidim.forms")
        template += @template.link_to file.file.filename, file.url, target: "_blank"
      end

      if file_is_present?(file)
        if options[:optional]
          template += content_tag :div, class: "field" do
            safe_join([
                        @template.check_box(@object_name, "remove_#{attribute}"),
                        label("remove_#{attribute}", I18n.t("remove_this_file", scope: "decidim.forms"))
                      ])
          end
        end
      end

      if object.errors[attribute].any?
        template += content_tag :p, class: "is-invalid-label" do
          safe_join object.errors[attribute], "<br/>".html_safe
        end
      end

      template.html_safe
    end
  end
end
