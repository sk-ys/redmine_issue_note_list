function fixPopUpWindowPosition($dialog) {
  if ($dialog.hasClass("fix-to-right")) {
    $dialog.css("left", $(window).width() - $dialog.outerWidth());
  } else if ($dialog.hasClass("fix-to-bottom")) {
    $dialog.css("top", $(window).height() - $dialog.outerHeight());
  }
}

function toggleNotesPopOutState(elem, title) {
  const $note = $(elem);
  const $noteParent = $note.parent();
  const dialogStyle = {
    width: 700,
    height: 300,
  };

  // Keep current height
  $noteParent.css("height", $noteParent.height());

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

    function generateResizeWindowButton(className, icon, label, func = null) {
      return $("<button/>")
        .addClass(className)
        .button({
          icon: icon,
          label: label,
          showLabel: false,
        })
        .on("click", (e) => {
          const $dialog = $(e.target).closest(".ui-dialog.note-pop-out-dialog");
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

    const $restoreButton = $("<button/>")
      .addClass("restore")
      .button({
        icon: "ui-icon-newwin",
        label: IssueNoteList.resources.labelRestore,
        showLabel: false,
      })
      .on("click", (e) => {
        const $dialog = $(e.target).closest(".ui-dialog.note-pop-out-dialog");
        removeAllClasses($dialog);
        $dialog.css(storedSize);
      });

    const $fixToLeftButton = generateResizeWindowButton(
      "fixed fix-to-left",
      "ui-icon-arrowstop-1-w",
      IssueNoteList.resources.labelFixToLeft
    );

    const $fixToRightButton = generateResizeWindowButton(
      "fixed fix-to-right",
      "ui-icon-arrowstop-1-e",
      IssueNoteList.resources.labelFixToRight,
      ($dialog) => {
        $dialog.css("left", $(window).width() - $dialog.outerWidth());
      }
    );

    const $fixToTopButton = generateResizeWindowButton(
      "fixed fix-to-top",
      "ui-icon-arrowstop-1-n",
      IssueNoteList.resources.labelFixToTop
    );

    const $fixToBottomButton = generateResizeWindowButton(
      "fixed fix-to-bottom",
      "ui-icon-arrowstop-1-s",
      IssueNoteList.resources.labelFixToBottom,
      ($dialog) => {
        $dialog.css("top", $(window).height() - $dialog.outerHeight());
      }
    );

    const $maximizeButton = generateResizeWindowButton(
      "maximized",
      "ui-icon-stop",
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
      .append($restoreButton)
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
      $noteParent.css("height", "");
    },
    resizeStop: () => {
      const $dialog = $note.dialog("widget");
      fixPopUpWindowPosition($dialog);
    },
  });
}

function setNoteHeightVariable(e, state = true) {
  const $target =
    e === "all" || e.ctrlKey || e.metaKey
      ? $("table.list.issues").find("tr.issue")
      : $(e.target).closest("tr.issue");
  $target.toggleClass("variable-height", state);
}

function collapseNoteRow(e, state = false) {
  const $target =
    e === "all" || e.ctrlKey || e.metaKey
      ? $("table.list.issues").find("tr.issue")
      : $(e.target).closest("tr.issue");
  $target.toggleClass("collapse-row", state);
}

$(() => {
  $(window).on("resize", (e) => {
    if (e.target === window) {
      const $dialogs = $(".ui-dialog.note-pop-out-dialog");
      $dialogs.each((i, dialog) => {
        fixPopUpWindowPosition($(dialog));
      });
    }
  });

  // Set resizable
  $("td.issue-status").resizable({
    handles: "e",
    alsoResize:
      "td.issue-status > div.column-items, td.issue-status > div.header",
    minWidth: $("td.issue-status").width(),
  });
  $("td.add-notes").resizable({ handles: "w" });

  // Set notes field height
  function generateNotesFieldHeightStyle(height) {
    return `table.list.issues > tbody > tr > td { height: ${height}px; }`;
  }
  const $notes_field_height_style = $("<style />")
    .text(generateNotesFieldHeightStyle($("#notes_field_height").val()))
    .appendTo("head");

  // Setup adjust notes field height slider
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
  $("#notes_field_height").on("change", function () {
    const notes_field_height = parseInt($(this).val());
    $("#adjust_notes_field_height_slider").slider("value", notes_field_height);
    $notes_field_height_style.text(
      generateNotesFieldHeightStyle(notes_field_height)
    );
  });

  // Explicitly state whether the query condition is valid or invalid
  function updateFieldStatus() {
    const enable_compact_mode = $("#enable_compact_mode")[0].checked;
    const enable_variable_height = $("#enable_variable_height")[0].checked;
    $("#enable_variable_height").prop("disabled", enable_compact_mode);
    $("#notes_field_height").prop(
      "disabled",
      enable_variable_height || enable_compact_mode
    );
    $("#adjust_notes_field_height_slider").slider(
      "option",
      "disabled",
      enable_variable_height || enable_compact_mode
    );
  }
  $("#enable_compact_mode").on("change", updateFieldStatus);
  $("#enable_variable_height").on("change", updateFieldStatus);
  updateFieldStatus(); // Initialize
});
