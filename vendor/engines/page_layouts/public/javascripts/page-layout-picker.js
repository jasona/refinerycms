var page_migration = {
  current_id: null,
  available_layouts: null,
  init: function(current_id, available_layouts) {
    page_migration.original_id = current_id;
    page_migration.current_id  = current_id;

    page_migration.available_layouts = available_layouts;

    page_migration.init_list();

    if (current_id != false) {
      page_migration.create_migrate_from(page_migration.original_id);
    }

    $("#migrate").hide();

    $("#layouts li").bind("click", page_migration.pick_layout);

    $("#layouts li[data-id='" + current_id + "']").click();

  },
  init_list: function () {
    $.each(page_migration.available_layouts, function(i, layout) {
      var li = $("<li>");
      li.html(layout.page_layout.title)
      li.attr('data-id',layout.page_layout.id);
      li.appendTo($("#layouts"));
    });
  },
  pick_layout: function () {
    var current_id = $(this).attr("data-id");
    page_migration.current_id = current_id;

    page_migration.update_selection($(this), current_id);
    page_migration.update_detail_view(current_id);
    page_migration.clear_migrate_to();

    if (page_migration.original_id != false) {
      if (page_migration.original_id == current_id) {
        $("#migrate").hide();
      } else {
        $("#migrate").show();
        page_migration.create_migrate_to(current_id, page_migration.original_id);
      }
    } else {
      $("#migrate").hide();
    }
  },
  update_selection: function(current, current_id) {
    $("#layouts li").removeClass("selected");
    current.addClass("selected");
    $("#layout_id").val(current_id);
    page_migration.update_value();
  },
  update_detail_view: function(current_id) {
    // Set detail view
    var layout = page_migration.find_layout_by_id(current_id);

    var description = layout.description || "No description available";
    $("#details_description p").html(description);

//    var preview_image = ("data-preview-image");
//    if (preview_image != undefined && preview_image.length > 0) {
//      $("#details_preview img").attr('src', preview_image);
//      $("#details_preview").show();
//    } else {
      $("#details_preview").hide();
//    }

    var part_titles = [];
    $.each(layout.parts, function (i, part) {
      part_titles.push(part.title);
    });

    $("#details_parts p").html(part_titles.join(", "));
  },
  find_layout_by_id: function(id) {
    for (key in page_migration.available_layouts) {
      var item = page_migration.available_layouts[key];
      if (item.page_layout.id == id) {
        return item.page_layout;
      }
    }
    return null;
  },
  clear_migrate_to: function() {
    $("#migrate_to > div > div").droppable("destroy");
    $("#migrate_to > div ").remove();
  },
  create_migrate_from: function(original_id) {
    var original_layout = page_migration.find_layout_by_id(original_id);
    var migrate_from = $("#migrate_from");

    $.each(original_layout.parts, function (i, part) {
      $("<div>").html(part.title).attr("data-name", part.name).addClass("page_part").appendTo(migrate_from);
    });
    $("#migrate_from > div ").draggable({
      revert: true
    });
  },
  create_migrate_to: function(current_id, original_id) {
    var current_layout  = page_migration.find_layout_by_id(current_id);

    var migrate_to   = $("#migrate_to");

    $.each(current_layout.parts, function (i, part) {
      var migrate_part = $("<div><span/><ul/></div>").attr("data-name", part.name).addClass("clearfix").appendTo(migrate_to);
      $("span", migrate_part).html(part.title);
    });
    $("#migrate_to > div > ul").droppable({
      drop: function(event, ui) {
        var li = $("<li>").attr("data-name", ui.helper.attr("data-name"));
        li.html(ui.helper.html());
        var close = $("<span>").addClass("close").html(" X").appendTo(li);
        
        close.click(function () {
          $(this).parent().remove();
          page_migration.update_value();
        });

        li.appendTo(event.target);
        page_migration.update_value();
      }
    });
  },
  update_value: function() {
    var mapping = {};
    $("#migrate_to > div").each(function (i, element) {
      mapping_key = $(element).attr('data-name');
      mapping[mapping_key] = [];
      $(element).find("li").each(function (i, li) {
        mapping[mapping_key].push($(li).attr('data-name'));
      });
    });
    page_migration.mapping = mapping; // Use later for warnings etc
    $("#mapping_value").val($.toJSON(mapping));
  }
};
