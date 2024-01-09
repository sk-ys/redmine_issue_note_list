module IssueNoteList
  module Patches
    module JournalsControllerPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods

        alias_method :new_without_issue_note_list, :new
        alias_method :new, :new_with_issue_note_list
      end

      module InstanceMethods
        def new_with_issue_note_list
          new_without_issue_note_list

          if params[:issue_note_list]
            render template: 'issue_note_list/quote'
          end
        end
      end
    end
  end
end

JournalsController.send(:include, IssueNoteList::Patches::JournalsControllerPatch)
