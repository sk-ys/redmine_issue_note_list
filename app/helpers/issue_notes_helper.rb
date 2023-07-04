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
    content << "<div class=\"issue-note\">"
    content <<   "<h4 class=\"note-header\">"
    content <<     content_tag(:div, button_tag(
                     '', class: "ui-icon collapse-expand", type: "button",
                     onclick: "$(this).closest('div.issue-note').toggleClass('expanded')"
                   ), class: 'header-buttons')
    content <<     link_to(
                    format_time(journal.updated_on),
                    @project.present? ?
                    project_activity_path(@project, :from => User.current.time_to_date(journal.updated_on)) :
                    activity_path( :from => User.current.time_to_date(journal.updated_on))
                  )
    content <<     render_private_notes_indicator(journal)
    content <<   "</h4>"
    content <<   "<div class=\"note-info\">"
    content <<     l(journal.created_on == journal.updated_on ? :field_author : :field_updated_by).html_safe +
                    ": " + link_to_user(journal.user)
    content <<   "</div>"
    content <<   render_notes(issue, journal)
    content << "</div>"

    content.html_safe
  end
end
