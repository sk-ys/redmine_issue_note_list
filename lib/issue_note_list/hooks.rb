class IssueNoteList::Hooks < Redmine::Hook::ViewListener
  render_on :view_journals_update_js_bottom,
            partial: 'issue_note_list/journals_update_js_bottom'
  render_on :view_journals_notes_form_after_notes,
            partial: 'issue_note_list/journals_notes_form_after_notes'
end
