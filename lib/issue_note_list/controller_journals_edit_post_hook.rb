module IssueNoteList
  class ControllerJournalsEditPostHook < Redmine::Hook::Listener
    include IssueNoteListHelper

    def controller_journals_edit_post(context={})
      # Only apply filtering logic for issue_note_list context
      return unless context[:params][:issue_note_list].present?

      journal = context[:journal]

      # Get filter parameters from request
      params = context[:params]
      filter = params[:filter]
      return unless filter.present?

      private_notes_filter = filter[:private_notes_filter].presence || 'contains'
      note_type_op = filter[:note_type_op].presence || '*'
      note_type_v = Array(filter[:note_type_v].presence)
      number_of_notes = filter[:number_of_notes].presence&.to_i || 2

      # Check if journal still matches filter criteria
      passes_private_filter = filter_private_notes(journal, private_notes_filter)
      passes_type_filter = filter_note_type(journal, note_type_op, note_type_v)

      # Store filter options in request env for view template
      filter_opts = {
        number_of_notes: number_of_notes,
        private_notes_filter: private_notes_filter,
        note_type_op: note_type_op,
        note_type_v: note_type_v
      }
      context[:request].env['issue_note_list.filter_opts'] = filter_opts

      # Store result in request env for view template
      unless passes_private_filter && passes_type_filter
        context[:request].env['issue_note_list.journal_filtered_out'] = true
        context[:request].env['issue_note_list.issue'] = journal.journalized
      end
    end
  end
end
