@page_layouts
Feature: Page Layouts
  In order to have page_layouts on my website
  As an administrator
  I want to manage page_layouts

  Background:
     Given I am a logged in refinery user
     And I have no page_layouts

   Scenario: Page Layouts List
     Given I have page_layouts titled UniqueTitleOne, UniqueTitleTwo
     When I go to the list of page_layouts
     Then I should see "UniqueTitleOne"
     And I should see "UniqueTitleTwo"

   Scenario: Create Valid Page Layout
     When I go to the list of page_layouts
     And I follow "Add New Page Layout"
     And I fill in "Title" with "This is a test of the first string field"
     And I press "Save"
     Then I should see "'This is a test of the first string field' was successfully added."
     And I should have 1 page_layout

   Scenario: Create Invalid Page Layout (without title)
     When I go to the list of page_layouts
     And I follow "Add New Page Layout"
     And I press "Save"
     Then I should see "Title can't be blank"
     And I should have 0 page_layouts

   Scenario: Create Duplicate Page Layout
     Given I only have page_layouts titled UniqueTitleOne, UniqueTitleTwo
     When I go to the list of page_layouts
     And I follow "Add New Page Layout"
     And I fill in "Title" with "UniqueTitleTwo"
     And I press "Save"
     Then I should see "There were problems"
     And I should have 2 page_layouts

   Scenario: Delete Page Layout
     Given I only have page_layouts titled UniqueTitleOne
     When I go to the list of page_layouts
     And I follow "Remove this page layout forever"
     Then I should see "'UniqueTitleOne' was successfully removed."
     And I should have 0 page_layouts
 