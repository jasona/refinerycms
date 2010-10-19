class PageLayoutsController < ApplicationController

  before_filter :find_all_page_layouts
  before_filter :find_page

  def index
    # you can use meta fields from your model instead (e.g. browser_title)
    # by swapping @page for @page_layout in the line below:
    present(@page)
  end

  def show
    @page_layout = PageLayout.find(params[:id])

    # you can use meta fields from your model instead (e.g. browser_title)
    # by swapping @page for @page_layout in the line below:
    present(@page)
  end

protected

  def find_all_page_layouts
    @page_layouts = PageLayout.find(:all, :order => "position ASC")
  end

  def find_page
    @page = Page.find_by_link_url("/page_layouts")
  end

end
