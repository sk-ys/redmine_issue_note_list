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

class IssueNoteListController < ApplicationController
  unloadable
  menu_item :redmine_issue_note_list
  before_action :find_optional_project, :only => [:index]
  before_action :find_issue, :only => [:add_note]
  before_action :find_journal, :authorize_edit_journal, :only => [:delete_note]
  before_action :retrieve_queries_with_session, :only => [:index, :add_note, :delete_note]

  helper :issues
  helper :queries
  helper :journals
  include QueriesHelper
  helper IssuesTagsHelper if defined?(IssuesTagsHelper) # Support for RedmineUP Tags plugin >= 2.0.14

  def index
    @is_global = @project == nil
    if @is_global
      @allowed_to_add_note = Setting.plugin_redmine_issue_note_list[:add_note_to_issue_note_list_on_global]
    else
      @allowed_to_add_note = User.current.allowed_to?(:add_note_to_issue_note_list, @project)
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def add_note
    @saved = false
    if update_issue_from_params
      begin
        @saved = save_issue_with_child_records == true
      rescue ActiveRecord::StaleObjectError
      end
    end
    render 'add_note'
  end

  def delete_note
    @journal.destroy
    render 'delete_note'
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

  def retrieve_queries_with_session
    use_session = true
    retrieve_default_query(use_session)
    retrieve_query(IssueQuery, use_session)

    if @query.valid?
      @issue_count = @query.issue_count
      @issue_pages = Paginator.new @issue_count, per_page_option, params['page']
      @issues = @query.issues(:offset => @issue_pages.offset, :limit => @issue_pages.per_page)
    end
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
    raise Unauthorized unless @issue.visible?

    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_journal
    @journal = Journal.visible.find(params[:journal_id])
    @issue = @journal.issue
    @project = @journal.journalized.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Saves @issue and a time_entry from the parameters
  def save_issue_with_child_records
    Issue.transaction do
      if params[:time_entry] &&
           (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) &&
           User.current.allowed_to?(:log_time, @issue.project)
        time_entry = @time_entry || TimeEntry.new
        time_entry.project = @issue.project
        time_entry.issue = @issue
        time_entry.author = User.current
        time_entry.user = User.current
        time_entry.spent_on = User.current.today
        time_entry.safe_attributes = params[:time_entry]
        @issue.time_entries << time_entry
      end
      call_hook(
        :controller_issues_edit_before_save,
        {:params => params, :issue => @issue,
         :time_entry => time_entry,
         :journal => @issue.current_journal}
      )
      if @issue.save
        call_hook(
          :controller_issues_edit_after_save,
          {:params => params, :issue => @issue,
           :time_entry => time_entry,
           :journal => @issue.current_journal}
        )
        true
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  # Used by #edit and #update to set some common instance variables
  # from the params
  def update_issue_from_params
    @time_entry = TimeEntry.new(:issue => @issue, :project => @issue.project)
    if params[:time_entry]
      @time_entry.safe_attributes = params[:time_entry]
    end
    @issue.init_journal(User.current)
    issue_attributes = params[:issue]
    if issue_attributes && issue_attributes[:assigned_to_id] == 'me'
      issue_attributes[:assigned_to_id] = User.current.id
    end
    if issue_attributes && params[:conflict_resolution]
      case params[:conflict_resolution]
      when 'overwrite'
        issue_attributes = issue_attributes.dup
        issue_attributes.delete(:lock_version)
      when 'add_notes'
        issue_attributes = issue_attributes.slice(:notes, :private_notes)
      when 'cancel'
        redirect_to issue_path(@issue)
        return false
      end
    end
    issue_attributes = replace_none_values_with_blank(issue_attributes)
    @issue.safe_attributes = issue_attributes
    @priorities = IssuePriority.active
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    true
  end

  def authorize_add_journal
    authorize
    authorize_for :journal, :new
  end

  def authorize_edit_journal
    authorize_for :journal, :edit
  end
end
