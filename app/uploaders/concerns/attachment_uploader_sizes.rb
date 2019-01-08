module AttachmentUploaderSizes
  extend ActiveSupport::Concern

  included do
    process :orientate, if: :image?
    process :strip, if: :image?

    version :thumbnail, if: :image? do
      process resize_to_fill: [430, 430]
    end

    version :thumbnail_small, if: :image? do
      process resize_to_fill: [330, 330]
    end

    version :main, if: :image? do
      process resize_to_fill: [1180, 700]
    end

    # Same maximum height as `main` but will retain the aspect ratio of the
    # original image.
    version :main_aspect, if: :image? do
      process resize_to_fit: [nil, 700]
    end

    # Same maximum width as `main` but will retain the aspect ratio of the
    # original image.
    version :main_original, if: :image? do
      process resize_to_limit: [1180, nil]
    end

    version :hero, if: :image? do
      process resize_to_fill: [2000, 580]
    end
  end

  protected
    # Flips the image to be in correct orientation based on its Exif orientation
    # metadata.
    def orientate
      manipulate! do |img|
        img.tap(&:auto_orient)
        img = yield(img) if block_given?
        img
      end
    end

    # Strips the embedded Exif metadata from the image. Fixes e.g. Apple images
    # carrying the orientation which causes the images to flip on Apple devices.
    def strip
      manipulate! do |img|
        img.strip
        img = yield(img) if block_given?
        img
      end
    end
end
