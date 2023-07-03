class IssueNotesController < ApplicationController
  unloadable
  menu_item :issue_notes
  before_action :find_optional_project, :authorize

  def index
  end
end
