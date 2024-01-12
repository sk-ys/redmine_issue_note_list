# Patch for https://github.com/alphanodes/redmine_lightbox

module IssueNoteList
  module Patches
    module RedmineLightboxPluginPatch
      def lightbox_plugins_controllers
          controllers = super
          if controllers.exclude? "IssueNoteListController"
            controllers << "IssueNoteListController"
          end
          controllers
        end
    end
  end
end

if Module.const_defined?("RedmineLightbox")
  RedmineLightbox.singleton_class.prepend(IssueNoteList::Patches::RedmineLightboxPluginPatch)
  Rails.logger.info "RedmineLightboxPluginPatch prepended"
end
