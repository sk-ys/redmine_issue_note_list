# This program is based on redmine/app/controllers/issues_controller.rb

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

class IssueNotesController < ApplicationController
  unloadable
  menu_item :issue_notes
  before_action :find_optional_project

  helper :issues
  helper :queries
  include QueriesHelper

  def index
    use_session = !request.format.csv?
    retrieve_default_query(use_session)
    retrieve_query(IssueQuery, use_session)

    if @query.valid?
      @issue_count = @query.issue_count
      @issue_pages = Paginator.new @issue_count, per_page_option, params['page']
      @issues = @query.issues(:offset => @issue_pages.offset, :limit => @issue_pages.per_page)
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private

  def retrieve_default_query(use_session)
    return if params[:query_id].present?
    return if api_request?
    return if params[:set_filter]

    if params[:without_default].present?
      params[:set_filter] = 1
      return
    end
    if !params[:set_filter] && use_session && session[:issue_query]
      query_id, project_id = session[:issue_query].values_at(:id, :project_id)
      return if IssueQuery.where(id: query_id).exists? && project_id == @project&.id
    end
    if default_query = IssueQuery.default(project: @project)
      params[:query_id] = default_query.id
    end
  end
end
