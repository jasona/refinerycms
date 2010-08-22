class Admin::PagesController < Admin::BaseController

  crudify :page,
          :conditions => "parent_id IS NULL",
          :order => "position ASC",
          :include => [:parts, :slugs, :children],
          :paging => false

  before_filter :find_pages_for_parents_list, :only => [:new, :create, :edit, :update]
  after_filter :expire_caching, :only => [:create, :update, :destroy, :update_positions]

  rescue_from FriendlyId::ReservedError, :with => :show_errors_for_reserved_slug

  def new_choose_page_layout
  end


  def new
    if params[:layout].blank? or (layout = PageLayout.all.find_by_name params[:layout]).nil?
      flash[:notice] = "You have to select a page layout, in order to add a new page"
      redirect_to choose_page_layout_new_admin_page_url
    else
      @page = Page.new
      @page.page_layout = layout.name
      layout.parts.each_with_index do |page_part, index|
        @page.parts << PagePart.new(:name => page_part, :position => index)
      end
    end
  end

  def migrate_layout
    @page = Page.find params[:id]
    @page.migrate_layout_to params[:layout], params[:available_parts], params[:migrate_parts]
    flash[:notice] = "Successfully migrated the layout!"
    render :json => :ok
  end

protected
  def expire_caching
    expire_menu_fragment_caching
    expire_action_caching
  end

  def expire_menu_fragment_caching
    Rails.cache.delete("#{Refinery.base_cache_key}_menu_pages")
    expire_fragment %r{#{RefinerySetting.find_or_set(:refinery_menu_cache_action_suffix, "site_menu")}}
  end

  def expire_action_caching
    expire_fragment %r{.*/pages/.*}
  end

  # This finds all of the pages that could possibly be assigned as the current page's parent.
  def find_pages_for_parents_list
    @pages_for_parents_list = []
    Page.find_all_by_parent_id(nil, :order => "position ASC").each do |page|
      @pages_for_parents_list << page
      @pages_for_parents_list += add_pages_branch_to_parents_list(page)
    end
    @pages_for_parents_list.flatten.compact!

    # We need to remove all references to the current page or any of its decendants or we get a nightmare.
    @pages_for_parents_list.reject! do |page|
      page.id == @page.id or @page.descendants.include?(page)
    end unless @page.nil? or @page.new_record?
  end

  def add_pages_branch_to_parents_list(page)
    list = []
    page.children.each do |child|
      list << child
      list += add_pages_branch_to_parents_list(child) if child.children.any?
    end
    list
  end

  def show_errors_for_reserved_slug(exception)
    flash[:error] = "Sorry, but that title is a reserved system word."
    if params[:action] == 'update'
      find_page
      render :edit
    else
      @page = Page.new(params[:page])
      render :new
    end
  end

end
