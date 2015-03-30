jQuery(document).ready(function () {
    var $categoriesTable = $('#release_log_entry_categories'),
        $categoryTemplate = $('#release_log_entry_category_template'),
        $addNewCategoryLink = $('#add_new_category'),
        currentIndex = $categoriesTable.find('.release-log-category-row').length;

    var removeEntryCategory = function () {
      var $element = $(this),
          $row = $element.closest('p.release-log-category-row');

       if($row.find('input[type="hidden"]').length > 0) {
            $row.hide();
            $row.find('input[type="hidden"]').removeAttr('disabled');
       } else {
           $row.remove();
       }
    };

    $addNewCategoryLink.on('click', function () {
        var content = $($categoryTemplate.html()).clone();
        counter = currentIndex++;
        $categoriesTable.append($('<p class="release-log-category-row" data-index="' + counter + '"></p>').append(content));

        var newContent = $('p[data-index="' + counter + '"]');
        newContent.find('input[type="text"]').removeAttr('disabled');
        newContent.find('.remove-entry-category').on('click', removeEntryCategory);
    });

    $('.remove-entry-category').on('click', removeEntryCategory);
});
