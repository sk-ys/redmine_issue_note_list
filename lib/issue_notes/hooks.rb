class IssueNotes::Hooks < Redmine::Hook::ViewListener
  render_on :view_journals_update_js_bottom,
            partial: 'issue_notes/journals_update_js_bottom'
end
