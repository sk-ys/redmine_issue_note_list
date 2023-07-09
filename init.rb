Redmine::Plugin.register :redmine_issue_note_list do
  name "Redmine Issue Note List plugin"
  author "sk-ys"
  description "This is a plugin for Redmine"
  version "0.0.1"
  url "https://github.com/sk-ys/redmine_issue_note_list"
  author_url "https://github.com/sk-ys"

  project_module :issue_note_list do
    permission :view_issue_notes, :issue_notes => :index
  end

  menu :application_menu, :redmine_issue_note_list,
    { :controller => "issue_notes", :action => "index" }, :after => :issues
  menu :project_menu, :redmine_issue_note_list,
    { :controller => "issue_notes", :action => "index" }, :after => :issues,
    :param => :project_id

end
