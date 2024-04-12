module IssueNoteList
  module Patches
    module QueriesControllerPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods

        alias_method :redirect_to_issue_query_without_issue_note_list, :redirect_to_issue_query
        alias_method :redirect_to_issue_query, :redirect_to_issue_query_with_issue_note_list
      end

      module InstanceMethods
        def redirect_to_issue_query_with_issue_note_list(options)
          if params[:issue_note_list]
            if @project
              redirect_to project_issue_note_list_index_path(@project, options)
            else
              redirect_to issue_note_list_index_path(options)
            end
          else
            redirect_to_issue_query_without_issue_note_list(options)
          end
        end
      end
    end
  end
end

QueriesController.send(:include, IssueNoteList::Patches::QueriesControllerPatch)
