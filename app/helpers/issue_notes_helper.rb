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
  def column_names(query, column, options={})
    if column.sortable?
      css, order = nil, column.default_order
      if column.name.to_s == query.sort_criteria.first_key
        if query.sort_criteria.first_asc?
          css = 'sort asc icon icon-sorted-desc'
          order = 'desc'
        else
          css = 'sort desc icon icon-sorted-asc'
          order = 'asc'
        end
      end
      param_key = options[:sort_param] || :sort
      sort_param = {param_key => query.sort_criteria.add(column.name, order).to_param}
      sort_param = {$1 => {$2 => sort_param.values.first}} while sort_param.keys.first.to_s =~ /^(.+)\[(.+)\]$/
      link_options = {
        :title => l(:label_sort_by, "\"#{column.caption}\""),
        :class => css
      }
      if options[:sort_link_options]
        link_options.merge! options[:sort_link_options]
      end
      content =
        link_to(
          column.caption,
          {:params => request.query_parameters.deep_merge(sort_param)},
          link_options
        )
    else
      content = column.caption
    end
    content_tag('span', content, :class => column.css_classes)
  end
  
  def _project_issue_notes_path(project, *args)
    if project
      project_issue_notes_path(project, *args)
    else
      issue_notes_path(*args)
    end
  end

  def render_issue_note(issue, journal)
    project = issue.project

    content = +''
    content << "<div class=\"#{journal.css_classes}\" id=\"change-#{journal.id}\">"
    content <<   "<h4 class=\"note-header\">"
    content <<     "<div class=\"header-text\">"
    content <<       link_to(
                       format_time(journal.created_on),
                       @project.present? ?
                       project_activity_path(@project, :from => User.current.time_to_date(journal.created_on)) :
                       activity_path( :from => User.current.time_to_date(journal.created_on))
                     )
    content <<       render_private_notes_indicator(journal)
    content <<       (respond_to?(:render_journal_update_info) ? (render_journal_update_info(journal) || '') : '')
    content <<     "</div>"
    content <<     "<div class=\"header-buttons\">"
    if journal.editable_by?(User.current)
      content << link_to(l(:button_edit),
                         edit_journal_path(journal),
                         :remote => true,
                         :method => 'get',
                         :title => l(:button_edit),
                         :class => 'icon-only icon-edit'
      )
    end
    content <<       button_tag(
                       '', class: "expand ui-icon ui-icon-caret-1-s", type: "button",
                       onclick: "$(this).closest('div.journal.has-notes').addClass('expanded')",
                       title: l(:issue_note_list_label_expand)
                     )
    content <<       button_tag(
                       '', class: "collapse ui-icon ui-icon-caret-1-n", type: "button",
                       onclick: "$(this).closest('div.journal.has-notes').removeClass('expanded')",
                       title: l(:issue_note_list_label_collapse)
                      )
    content <<       button_tag(
                       '', class: "ui-icon ui-icon-arrowreturnthick-1-n pop-out",
                       type: "button",
                       onclick: "ToggleNotesPopOutState(" +
                        "$(this).closest(\"div.journal.has-notes\"), " +
                        "'##{issue.id}: #{issue.subject} - #{l(:field_notes)}-#{journal.indice}');",
                       title: l(:issue_note_list_label_pop_out)
                      )
    content <<     "</div>"
    content <<   "</h4>"
    content <<   "<div class=\"note-info\">"
    content <<     l(:field_updated_by).html_safe + ": " + link_to_user(journal.user)
    content <<   "</div>"
    content <<   render_notes(issue, journal)
    content << "</div>"

    content.html_safe
  end
end
