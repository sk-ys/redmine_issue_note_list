require_dependency File.expand_path('../lib/issue_note_list/hooks.rb', __FILE__)
Dir[File.join(File.expand_path('../lib/issue_note_list/patches', __FILE__), '*.rb')].each do |patch|
  require_dependency patch
end

Redmine::Plugin.register :redmine_issue_note_list do
  name "Redmine Issue Note List plugin"
  author "sk-ys"
  description "This is a plugin for Redmine"
  version "0.0.1"
  url "https://github.com/sk-ys/redmine_issue_note_list"
  author_url "https://github.com/sk-ys"

  project_module :issue_note_list do
    permission :view_issue_note_list, issue_note_list: :index
    permission :add_note_to_issue_note_list, issue_note_list: :add_note
  end

  menu :application_menu, :redmine_issue_note_list,
    { controller: "issue_note_list", action: "index" }, after: :issues
  menu :project_menu, :redmine_issue_note_list,
    { controller: "issue_note_list", action: "index" }, after: :issues,
                                                    param: :project_id

  settings default: {
    add_note_to_issue_note_list_on_global: false, 
    enable_silent_mode: false },
    partial: 'settings/issue_note_list'
end
