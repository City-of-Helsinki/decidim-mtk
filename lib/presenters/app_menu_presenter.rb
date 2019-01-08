
# frozen_string_literal: true

# A presenter to render menus
class AppMenuPresenter
  #
  # Initializes a menu for presentation
  #
  # @param name [Symbol] The name of the menu registry to be rendered
  # @param view [ActionView::Base] The view scope to render the menu
  # @param options [Hash] The rendering options for the menu entries
  #
  def initialize(name, view, options = {})
    @name = name
    @view = view

    @options = options
  end

  delegate :items, to: :evaluated_menu
  delegate :content_tag, :safe_join, to: :@view

  def evaluated_menu
    @evaluated_menu ||= begin
                          menu = Decidim::Menu.new(@name)
                          menu.build_for(@view)
                          menu
                        end
  end

  def render
    safe_join(menu_items)
  end

  protected

  def menu_items
    items.map do |menu_item|
      Decidim::MenuItemPresenter.new(menu_item, @view, @options).render
    end
  end
end
