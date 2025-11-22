module IssueNoteList
  module Patches
    module IssueQueryPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods

        alias_method :build_from_params_without_issue_note_list, :build_from_params
        alias_method :build_from_params, :build_from_params_with_issue_note_list
      end

      module InstanceMethods
        def number_of_notes
          (options[:number_of_notes].to_i if (options[:number_of_notes].to_i > 0)) || 2
        end

        def number_of_notes=(arg)
          options[:number_of_notes] = (arg.to_i > 0 ? arg.to_i : nil)
        end

        def enable_compact_mode
          r = options[:enable_compact_mode]
          r == '1'
        end

        def enable_compact_mode=(arg)
          options[:enable_compact_mode] = (arg == '1' ? '1' : nil)
        end

        def enable_variable_height
          r = options[:enable_variable_height]
          r == '1'
        end

        def enable_variable_height=(arg)
          options[:enable_variable_height] = (arg == '1' ? '1' : nil)
        end

        def notes_field_height
          (options[:notes_field_height].to_i if (options[:notes_field_height].to_i > 0)) || 150
        end

        def notes_field_height=(arg)
          options[:notes_field_height] = (arg.to_i > 0 ? arg.to_i : nil)
        end
        
        def issue_status_field_width
          (options[:issue_status_field_width].to_i if (options[:issue_status_field_width].to_i > 0)) || 300
        end

        def issue_status_field_width=(arg)
          options[:issue_status_field_width] = (arg.to_i > 0 ? arg.to_i : nil)
        end

        def enable_simple_editor
          r = options[:enable_simple_editor]
          r == '1'
        end

        def enable_simple_editor=(arg)
          options[:enable_simple_editor] = (arg == '1' ? '1' : nil)
        end

        def private_notes_filter
          return 'contains' unless ['contains', 'not_contains', 'only'].include?(options[:private_notes_filter])
          options[:private_notes_filter]
        end

        def private_notes_filter=(arg)
          return unless ['contains', 'not_contains', 'only'].include?(arg)
          options[:private_notes_filter] = arg
        end

        def inline_block_elements
          r = options[:inline_block_elements]
          r.nil? || r == '1'
        end

        def inline_block_elements=(arg)
          options[:inline_block_elements] = (['0', '1'].include?(arg) ? arg : nil)
        end

        def build_from_params_with_issue_note_list(params, defaults={})
          build_from_params_without_issue_note_list(params, defaults)

          self.number_of_notes =
            params[:number_of_notes] ||
              (params[:query] && params[:query][:number_of_notes]) || options[:number_of_notes]

          self.enable_compact_mode =
            params[:enable_compact_mode] ||
              (params[:query] && params[:query][:enable_compact_mode]) || options[:enable_compact_mode]

          self.enable_variable_height =
            params[:enable_variable_height] ||
              (params[:query] && params[:query][:enable_variable_height]) || options[:enable_variable_height]

          self.notes_field_height =
            params[:notes_field_height] ||
              (params[:query] && params[:query][:notes_field_height]) || options[:notes_field_height]

          self.issue_status_field_width =
            params[:issue_status_field_width] ||
              (params[:query] && params[:query][:issue_status_field_width]) || options[:issue_status_field_width]

          self.enable_simple_editor =
            params[:enable_simple_editor] ||
              (params[:query] && params[:query][:enable_simple_editor]) || options[:enable_simple_editor]

          self.private_notes_filter =
            params[:private_notes_filter] ||
              (params[:query] && params[:query][:private_notes_filter]) || options[:private_notes_filter]

          self.inline_block_elements =
            params[:inline_block_elements] ||
              (params[:query] && params[:query][:inline_block_elements]) || options[:inline_block_elements]

          self
        end
      end
    end
  end
end

IssueQuery.send(:include, IssueNoteList::Patches::IssueQueryPatch)
