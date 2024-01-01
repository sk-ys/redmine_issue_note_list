# Redmine - project management software
# Copyright (C) 2006-2023  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module IssueNotesHelper
  # This program is based on QueriesHelper#column_header
  def column_names(query, column, options = {})
    if column.sortable?
      css, order = nil, column.default_order
      if column.name.to_s == query.sort_criteria.first_key
        if query.sort_criteria.first_asc?
          css = "sort asc icon icon-sorted-desc"
          order = "desc"
        else
          css = "sort desc icon icon-sorted-asc"
          order = "asc"
        end
      end
      param_key = options[:sort_param] || :sort
      sort_param = { param_key => query.sort_criteria.add(column.name, order).to_param }
      sort_param = { $1 => { $2 => sort_param.values.first } } while sort_param.keys.first.to_s =~ /^(.+)\[(.+)\]$/
      link_options = {
        title: l(:label_sort_by, "\"#{column.caption}\""),
        class: css,
      }
      if options[:sort_link_options]
        link_options.merge! options[:sort_link_options]
      end
      content =
        link_to(
          column.caption,
          { params: request.query_parameters.deep_merge(sort_param) },
          link_options
        )
    else
      content = column.caption
    end
    content_tag("span", content, class: column.css_classes)
  end

  def _project_issue_notes_path(project, *args)
    if project
      project_issue_notes_path(project, *args)
    else
      issue_notes_path(*args)
    end
  end

  def render_journal_update_info_empty()
    content_tag("span", "", class: "update-info empty")
  end

  def render_issue_note(issue, journal)
    project = issue.project
    indice = journal.indice || journal.issue.visible_journals_with_index.find { |j| j.id == journal.id }.indice

    content = +""
    content << "<div class=\"#{journal.css_classes} issue-#{issue.id}\" id=\"change-#{journal.id}\">"
    content << "<h4 class=\"note-header\">"
    content << "<div class=\"header-text\">"
    content << "<span class=\"note-id\">#{l(:field_notes)}-#{indice}</span>"
    content << link_to(
      format_time(journal.created_on),
      @project.present? ?
        project_activity_path(@project, from: User.current.time_to_date(journal.created_on)) :
        activity_path(from: User.current.time_to_date(journal.created_on))
    )
    content << render_private_notes_indicator(journal)
    content << (respond_to?(:render_journal_update_info) ? (render_journal_update_info(journal) || render_journal_update_info_empty()) : "")
    content << "</div>"
    content << "<div class=\"header-buttons\">"
    if journal.editable_by?(User.current)
      content << link_to(l(:button_edit),
                         edit_journal_path(journal),
                         remote: true,
                         method: "get",
                         title: l(:button_edit),
                         class: "icon-only mui-icon-edit")
      content << link_to(l(:button_quote),
                        quoted_issue_path(issue, journal_id: journal, journal_indice: indice, issue_notes: 1),
                        remote: true,
                        method: "post",
                        title: l(:button_quote),
                        class: "icon-only mui-icon-chat_paste_go")
      content << link_to(l(:button_delete),
                        delete_note_issue_note_path(journal.id, number_of_notes: @number_of_notes),
                        remote: true,
                        method: 'delete',
                        title: l(:button_delete),
                        data: {confirm: l(:text_are_you_sure)},
                        class: 'icon-only mui-icon-delete'
                        )
    end
    content << button_tag(
      "", class: "pop-out mui-icon mui-icon-open_in_new",
          type: "button",
          onclick: "IssueNoteList.fn.toggleNotesPopOutState(" +
                   "$(this).closest(\"div.journal.has-notes\"), " +
                   "'##{issue.id}: #{issue.subject} - #{l(:field_notes)}-#{indice}');",
          title: l(:label_pop_out, scope: :issue_note_list),
    )
    content << "</div>"
    content << "</h4>"
    content << "<div class=\"note-info\">"
    content << l(:field_updated_by).html_safe + ": " + link_to_user(journal.user)
    content << "</div>"
    content << render_notes(issue, journal)
    content << "</div>"

    content.html_safe
  end

  def render_issue_notes(issue, number_of_notes)
    journals = issue.visible_journals_with_index
      .select{|journal| journal.notes.present?}
      .reverse
      .take(number_of_notes)

    content = +""
    (0..(number_of_notes - 1)).reverse_each do |num|
      content << '<div class="journal_outer">'
      if journals.count <= num
        content << '<div class="journal empty"></div>'
      else
        content << render_issue_note(issue, journals[num])
      end
      content << '</div>'
    end

    content.html_safe
  end

  def issue_row_classes(issue, level, enable_compact_mode, enable_variable_height)
    classes = [cycle("odd", "even"), issue.css_classes]
    classes << "idnt idnt-#{level}" if level > 0
    classes << "collapse-row" if enable_compact_mode
    classes << "variable-height" if enable_variable_height
    classes.join(" ")
  end
end
