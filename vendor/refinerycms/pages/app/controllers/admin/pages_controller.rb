class Admin::PagesController < Admin::BaseController

  crudify :page,
          :conditions => {:parent_id => nil},
          :order => "lft ASC",
          :include => [:parts, :slugs, :children, :parent],
          :paging => false

  rescue_from FriendlyId::ReservedError, :with => :show_errors_for_reserved_slug

  def new_choose_page_layout
  end

  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy, :update_positions]

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
