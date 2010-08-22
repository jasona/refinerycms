class Admin::PagePartsController < Admin::BaseController

  def new
    render :partial => "/admin/pages/page_part_field", :locals => {
      :part => PagePart.new(:name => params[:name], :body => params[:body]),
      :new_part => true,
      :part_index => params[:part_index]
    }
  end

  def destroy
    part = PagePart.find(params[:id])
    page = part.page
    if part.destroy
      page.reposition_parts!
      render :text => "'#{part.name}' deleted."
    else
      render :text => "'#{part.name}' not deleted."
    end
  end

end
