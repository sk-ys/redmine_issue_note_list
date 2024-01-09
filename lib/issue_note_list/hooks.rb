class IssueNoteList::Hooks < Redmine::Hook::ViewListener
  render_on :view_journals_update_js_bottom,
            partial: 'issue_note_list/journals_update_js_bottom'
end
