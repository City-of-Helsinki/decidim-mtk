module ApplicationHelper
  def main_space
    request.env["decidim.current_participatory_space"]
  end

  def main_component
    request.env["decidim.current_component"]
  end

  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end

  # Returns an image URL for a proposal object.
  #
  # ==== Types
  #
  # * <tt>:thumb</tt> - Thumbnail image for listings (optimal size: 430x430)
  # * <tt>:main</tt> - The main image e.g. for the proposal page (optimal size:
  #                    1180x700)
  # * <tt>:hero</tt> - The hero image e.g. for home page (optimal size:
  #                    2000x580)
  def proposal_image(proposal, type=:thumb, accept_placeholder=true)
    photo = proposal.attachments.find { |a| a.photo? }

    if photo
      versions = photo.file.versions
      vhandle = (type == :thumb) ? :thumbnail : type
      vhandle = :thumbnail unless versions.has_key?(vhandle)

      img = versions[vhandle].url
    else
      # Fall back to category image
      if proposal.category
        return category_image proposal.category, type
      elsif accept_placeholder
        img = 'categories/placeholder/thumb.jpg'
      else
        return nil
      end
    end

    asset_url img
  end

  # Returns an image URL for a category object.
  #
  # ==== Types
  #
  # * <tt>:thumb</tt> - Thumbnail image for listings (optimal size: 430x430)
  # * <tt>:main</tt> - The main image e.g. for the proposal page (optimal size:
  #                    1180x700)
  # * <tt>:hero</tt> - The hero image e.g. for home page (optimal size:
  #                    2000x580)
  def category_image(category, type=:thumb)
    type = :main if type == :main_original
    type = :thumb unless [:hero, :main, :thumb].include?(type)

    img = if handle = category_handle(category)
      "categories/#{type.to_s}/#{handle}.jpg"
    else
      "categories/placeholder/#{type.to_s}.jpg"
    end

    unless asset_exists?(img)
      'categories/placeholder/thumb.jpg'
    end

    asset_url img
  end

  def category_handle(category)
    Rails.application.config.category_handles[category.id]
  end
end
