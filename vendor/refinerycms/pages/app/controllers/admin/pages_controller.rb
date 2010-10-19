class Admin::PagesController < Admin::BaseController

  crudify :page,
          :conditions => {:parent_id => nil},
          :order => "lft ASC",
          :include => [:parts, :slugs, :children, :parent],
          :paging => false

  rescue_from FriendlyId::ReservedError, :with => :show_errors_for_reserved_slug

  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy, :update_positions]

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
