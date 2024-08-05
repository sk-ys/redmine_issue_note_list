var IssueNoteList = IssueNoteList || {};
IssueNoteList.fn = {
  fixPopUpWindowPosition($dialog) {
    if ($dialog.hasClass("fix-to-right")) {
      $dialog.css("left", $(window).width() - $dialog.outerWidth());
    } else if ($dialog.hasClass("fix-to-bottom")) {
      $dialog.css("top", $(window).height() - $dialog.outerHeight());
    }
  },

  toggleNotesPopOutState(elem, title) {
    const self = this;
    const $note = $(elem);
    const $noteParent = $note.parent();
    const dialogStyle = {
      width: 700,
      height: 300,
    };

    function addButtonsToDialogTitlebar($dialog) {
      const $titleBar = $dialog.find(".ui-dialog-titlebar");

      let storedSize = dialogStyle;

      function removeAllClasses($dialog) {
        $dialog.removeClass("maximized");
        $dialog.removeClass("fixed");
        $dialog.removeClass("fix-to-left");
        $dialog.removeClass("fix-to-top");
        $dialog.removeClass("fix-to-right");
        $dialog.removeClass("fix-to-bottom");
      }

      function generateResizeWindowButton(className, label, func = null) {
        function hasAllClassNames(className, target) {
          return className.split(" ").every((v) => target.includes(v));
        }
        return $("<button/>")
          .addClass("ui-button ui-corner-all ui-widget ui-button-icon-only")
          .addClass(className)
          .attr("title", label)
          .on("click", (e) => {
            const $dialog = $(e.target).closest(
              ".ui-dialog.note-pop-out-dialog"
            );
            if (hasAllClassNames(className, $dialog.attr("class").split(" "))) {
              // restore
              removeAllClasses($dialog);
              $dialog.css(storedSize);
              return;
            }

            if (!$dialog.hasClass("maximized") && !$dialog.hasClass("fixed")) {
              storedSize = {
                width: $dialog.width(),
                height: $dialog.height(),
                left: $dialog.position().left,
                top: $dialog.position().top,
              };
            }
            removeAllClasses($dialog);
            $dialog.addClass(className);
            if (func !== null) func($dialog);
          });
      }

      const $fixToLeftButton = generateResizeWindowButton(
        "fixed fix-to-left mui-icon mui-icon-dock_to_left",
        IssueNoteList.resources.labelFixToLeft
      );

      const $fixToRightButton = generateResizeWindowButton(
        "fixed fix-to-right mui-icon mui-icon-dock_to_right",
        IssueNoteList.resources.labelFixToRight,
        ($dialog) => {
          $dialog.css("left", $(window).width() - $dialog.outerWidth());
        }
      );

      const $fixToTopButton = generateResizeWindowButton(
        "fixed fix-to-top mui-icon mui-icon-dock_to_top",
        IssueNoteList.resources.labelFixToTop
      );

      const $fixToBottomButton = generateResizeWindowButton(
        "fixed fix-to-bottom mui-icon mui-icon-dock_to_bottom",
        IssueNoteList.resources.labelFixToBottom,
        ($dialog) => {
          $dialog.css("top", $(window).height() - $dialog.outerHeight());
        }
      );

      const $maximizeButton = generateResizeWindowButton(
        "maximized mui-icon",
        IssueNoteList.resources.labelMaximize
      );

      $("<div/>")
        .addClass("ui-dialog-titlebar-button-group")
        .addClass("buttons")
        .append($fixToLeftButton)
        .append($fixToRightButton)
        .append($fixToTopButton)
        .append($fixToBottomButton)
        .append($maximizeButton)
        .appendTo($titleBar);
    }

    // Add button to close pop-out window
    $noteParent.append(
      $("<div />")
        .addClass("close-pop-out-button-outer")
        .append(
          $("<button />")
            .button({
              icon: "ui-icon-cancel",
              label: IssueNoteList.resources.labelClosePopOut,
            })
            .on("click", () => {
              $note.dialog("close");
            })
        )
    );

    $note.dialog({
      appendTo: "#content",
      width: dialogStyle.width,
      height: dialogStyle.height,
      dialogClass: "note-pop-out-dialog",
      position: {
        my: "center",
        at: "center",
        of: $noteParent,
      },
      title: title,
      create: function () {
        const $dialog = $note.dialog("widget");
        addButtonsToDialogTitlebar($dialog);
        $dialog.css("position", "fixed");
      },
      open: function () {
        // Disable automatic display of tooltips in content.
        $(this).parent().focus();

        // Set height of dialog
        const $dialog = $note.dialog("widget");
        if ($dialog.length > 0 && $dialog[0].style.height === "auto") {
          if ($dialog.height() < dialogStyle.height) {
            $dialog.css({
              top:
                $dialog.position().top +
                ($dialog.height() - dialogStyle.height) / 2,
              height: dialogStyle.height,
            });
          } else {
            $dialog.css({ height: $dialog.height() });
          }
        }
      },
      close: () => {
        $noteParent.find("div.close-pop-out-button-outer").remove();
        $note.appendTo($noteParent).dialog("destroy");
        if (!$noteParent.parent().hasClass("variable-height")) {
          $noteParent.css("height", "");
        }
      },
      resizeStop: () => {
        const $dialog = $note.dialog("widget");
        self.fixPopUpWindowPosition($dialog);
      },
    });
  },

  setNoteHeightVariable(e, state = true) {
    let $target;
    if (e === "all" || e.ctrlKey || e.metaKey) {
      $target = $("table.list.issues > tbody > tr");
    } else {
      const issueId = $(e.target).closest("tr.issue").attr("id");
      $target = $(`#${issueId}, table.list.issues > tbody > tr.${issueId}`);
    }
    $target.toggleClass("variable-height", state);
    if (state) {
      $target.filter(":not(.collapse-row)").each((_, tr) => {
        const maxTdHeight = Math.max(
          ...$(tr)
            .children("td")
            .map((_, e) => parseInt($(e).css("height")))
            .toArray()
        );
        $(tr).children("td").css("height", maxTdHeight);
      });
    } else {
      $target.children("td").css("height", "");
      $target.find("> td > div.wiki").css("height", "");
    }
  },

  enableSimpleEditor(enable = true) {
    $("#content").toggleClass("simple-editor", enable);
  },

  collapseNoteRow(e, state = false) {
    let $target;
    if (e === "all" || e.ctrlKey || e.metaKey) {
      $target = $("table.list.issues > tbody > tr");
    } else {
      const issueId = $(e.target).closest("tr.issue").attr("id");
      $target = $(`#${issueId}, table.list.issues > tbody > tr.${issueId}`);
    }
    $target.toggleClass("collapse-row", state);
    if (!state) {
      setTimeout(() => {
        $target.filter(".variable-height").each((_, tr) => {
          IssueNoteList.fn.setNoteHeightVariable({ target: tr }, true);
        });
      });
    }
  },

  _scrollToNextNote(event, prev = true) {
    const scrollContainer = $("#content .autoscroll");
    const containerScrollTop = scrollContainer.scrollTop();
    const containerHeight = scrollContainer.height();
    const cellTops = scrollContainer
      .find("table.list.issues>tbody>tr.issue")
      .map((_, e) => $(e).position().top)
      .toArray();
    const scrollSpeed = 200;
    const scrollOnePage = event.ctrlKey || event.metaKey;
    const margin = 5;

    function getNewScrollTop(condition, modifier, defaultValue) {
      const filteredCellTops = cellTops.filter(condition);
      return filteredCellTops.length === 0
        ? defaultValue
        : modifier(filteredCellTops);
    }

    const scrollTop = prev
      ? getNewScrollTop(
          (i) =>
            i <
            containerScrollTop +
              cellTops[0] -
              (scrollOnePage ? containerHeight : margin),
          (arr) => arr.slice(-1)[0] - cellTops[0],
          0
        )
      : getNewScrollTop(
          (i) =>
            i >
            containerScrollTop +
              cellTops[0] +
              (scrollOnePage ? containerHeight : margin),
          (arr) => arr[0] - cellTops[0],
          cellTops.slice(-1)[0]
        );

    scrollContainer.animate({ scrollTop: scrollTop }, scrollSpeed);
  },

  nextNote(event) {
    this._scrollToNextNote(event, false);
  },

  prevNote(event) {
    this._scrollToNextNote(event, true);
  },

  toggleAddNotesField() {
    const container = $("div.autoscroll-outer");
    if (container.length === 0) return;

    const className = "hide-add-note-fields";
    container.toggleClass(className);
    localStorage.setItem(
      "issue-note-list_hide-add-note-fields",
      container.hasClass(className)
    );
  },

  submitAll() {
    if (!window.confirm(IssueNoteList.resources.textSubmitAllConfirmation)) {
      return;
    }

    $("form[id^=add_notes_form-]").each((_, e) => {
      if ($(e).find("textarea").val() !== "") {
        $(e).find("input[type=submit]")[0].click();
      }
    });
  },

  initialize() {
    const self = this;

    // Hide the new note field
    if (
      localStorage.getItem("issue-note-list_hide-add-note-fields") == "true"
    ) {
      $("div.autoscroll-outer").addClass("hide-add-note-fields");
    }

    $(window).on("resize.issueNoteList", (e) => {
      if (e.target === window) {
        const $dialogs = $(".ui-dialog.note-pop-out-dialog");
        $dialogs.each((i, dialog) => {
          self.fixPopUpWindowPosition($(dialog));
        });
      }
    });

    // Set resizable
    $("td.issue-status").resizable({
      handles: "e",
      alsoResize: "td.issue-status > div.header, td.issue-status > div.columns",
      start: function (e) {
        // Set width only for active element
        const width = $(e.target).width();
        $("td.issue-status").css("width", "");
        $(e.target).css("width", width);
      },
    });
    $("td.add-notes").resizable({
      handles: "w",
      start: function (e) {
        // Set width only for active element
        const width = $(e.target).width();
        $("td.add-notes").css("width", "");
        $(e.target).css("width", width);
      },
    });
    $("td.block_column").resizable({
      handles: "e",
      start: function (e) {
        // Set width only for active element
        const width = $(e.target).width();
        const firstClass = $(e.target).attr("class").split(" ")[0];
        $(`td.block_column.${firstClass}`).css("width", "");
        $(e.target).css("width", width);
      },
    });

    // Set notes field height
    function generateNotesFieldHeightStyle(height) {
      return `table.list.issues > tbody > tr.issue > td { height: ${height}px; }`;
    }
    const $notes_field_height_style = $("<style />")
      .text(generateNotesFieldHeightStyle($("#notes_field_height").val()))
      .appendTo("head");

    // Set up the slider to adjust the height of the notes field
    $("#adjust_notes_field_height_slider").slider({
      min: 100,
      max: 1000,
      step: 50,
      value: $("#notes_field_height").val(),
      slide: () => {
        setTimeout(() => {
          $("#notes_field_height")
            .val($("#adjust_notes_field_height_slider").slider("value"))
            .change();
        });
      },
    });
    $("#notes_field_height").on("change.issueNoteList", function () {
      const notes_field_height = parseInt($(this).val());
      $("#adjust_notes_field_height_slider").slider(
        "value",
        notes_field_height
      );
      $notes_field_height_style.text(
        generateNotesFieldHeightStyle(notes_field_height)
      );
    });

    // Enable simple editor
    this.enableSimpleEditor($("#enable_simple_editor:checked").length === 1);

    // Apply Resizable to cell height
    $("table.list.issues > tbody > tr").each(function () {
      $(this).resizable({
        handles: "s",
        alsoResize: $(this).children("td"),
        create: function () {
          const $tr = $(this);
          $tr.children(".ui-resizable-handle").on("dblclick", (e) => {
            // Reset height
            if (!$tr.hasClass("variable-height")) {
              $tr.addClass("variable-height");
              IssueNoteList.fn.setNoteHeightVariable(e, true);
            } else {
              $tr.removeClass("variable-height");
              IssueNoteList.fn.setNoteHeightVariable(e, false);
            }
          });
        },
        start: function () {
          $(this).addClass("variable-height");
        },
        stop: function () {
          $(this)
            .css("height", "")
            .find("> td.recent_notes" + ", > td.block_column > div.wiki")
            .css("width", "");
        },
        minHeight:
          $(this).has("td.block_column:not(.in_row)").length === 0 ? 100 : 30,
        autoHide: true,
      });
    });

    // Enable double-click editing
    $("td.recent_notes .journal.has-notes .wiki").on("dblclick", (e) => {
      const $journal = $(e.target).closest("div.journal.has-notes");
      const editButton = $journal.find(
        ".note-header .header-buttons a[href$=edit]"
      )[0];
      if (editButton) {
        editButton.click();
        window.getSelection().empty();
      }
    });

    // Focus on the textarea after clicking the Edit Journal button
    // Observe .wiki attribute updating
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (
          mutation.type === "attributes" &&
          mutation.attributeName === "style"
        ) {
          const $textarea = $(mutation.target)
            .closest(".journal.has-notes")
            .find("textarea.wiki-edit");
          if ($textarea.length > 0) {
            $textarea.focus();
            const textareaLength = $textarea.val().length;
            $textarea.get(0).setSelectionRange(textareaLength, textareaLength);
          }
        }
      });
    });

    $("td.recent_notes .journal.has-notes .wiki").each(function () {
      observer.observe(this, {
        attributes: true,
        childList: false,
        subtree: false,
      });
    });
  },
};

window.addEventListener("DOMContentLoaded", () => {
  IssueNoteList.fn.initialize();

  (function replaceRedmineUPTagsPluginLinks() {
    $(".tag-label-color a, .tag-label a").each((_, e) => {
      $(e).attr(
        "href",
        $(e).attr("href").replace("/issues?", "/issue_note_list?")
      );
    });
  })();
});
