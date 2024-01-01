module IssueNotes
  module Patches
    module JournalsControllerPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods

        alias_method :new_without_issue_notes, :new
        alias_method :new, :new_with_issue_notes
      end

      module InstanceMethods
        def new_with_issue_notes
          new_without_issue_notes

          if params[:issue_notes]
            render template: 'issue_notes/quote'
          end
        end
      end
    end
  end
end

JournalsController.send(:include, IssueNotes::Patches::JournalsControllerPatch)
