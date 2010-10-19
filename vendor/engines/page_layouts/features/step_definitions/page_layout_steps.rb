Given /^I have no page_layouts$/ do
  PageLayout.delete_all
end

Given /^I (only )?have page_layouts titled "?([^"]*)"?$/ do |only, titles|
  PageLayout.delete_all if only
  titles.split(', ').each do |title|
    PageLayout.create(:title => title)
  end
end

Then /^I should have ([0-9]+) page_layouts?$/ do |count|
  PageLayout.count.should == count.to_i
end
