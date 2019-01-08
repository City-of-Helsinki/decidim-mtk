# Include this in Decidim::AttachmentForm
module ImageAttachmentForm
  extend ActiveSupport::Concern

  included do
    validate :has_to_be_photo, if: ->(form) { form.file.present? }
  end

  private
    def has_to_be_photo
      unless photo?
        errors.add(:file, :has_to_be_photo)
      end
    end

    # Whether this attachment is a photo or not.
    #
    # Returns Boolean.
    def photo?
      file.content_type.start_with? "image"
    end
end
