function showMoreLessLinks(event) {
  // Use the event to get the id of the element that invoked the function
  var currentElement = Event.element(event);

  // Get the parent node of that element and the value of it's "rel" attribute
  var toggleContainer = $(currentElement).parentNode;

  // Get the toggle caption based on the html of the clicked element
  var toggleCaption = ($(currentElement).innerHTML.toLowerCase() == readMoreText) ? readLessText : readMoreText;

  // Update the current element with the new caption value
  $(currentElement).update(toggleCaption);

  // If the container to be toggled exists, toggle it's visibility
  if (toggleContainer) {
    var toggleContainerParent = toggleContainer.parentNode;
    if (toggleContainerParent) {
      var moreTexts = toggleContainerParent.select('.more-text');
      moreTexts.each(function(element){
        element.toggle();
      });
    }
  }

  // Return false so the link does not go anywhere
  return false;
}